require 'octokit'
require 'aws-sdk-ssm'

class ::Project
  class GitHub
    NETRC_NAME = 'api.github.com'.freeze
    AUTHORIZATION_NAME = 'Dev server token'.freeze
    SCOPES = ['repo'].freeze

    attr_reader :client

    def initialize
      @client = login
    end

    def login
      authorize_credentials_from_aws
    rescue Octokit::Unauthorized => e
      puts "Local auth is invalid (#{e.message}). Re-authorizing with username/password"
      authorize_oauth
      retry
    end

    def authorize_credentials_from_aws
      user = ENV.fetch('USER') # This should error if the user variable doesn't exist
      # Try to load our profile from netrc
      github_oauth_token = Aws::SSM::Client.new.get_parameter(name: "/local/#{user}/github/oauth_token", with_decryption: true).parameter.value
      client = Octokit::Client.new(access_token: github_oauth_token)

      # This will raise 'Octokit::Unauthorized' if we are not authorized
      client.user

      client
    end

    def authenticated?
      client.user
      true
    rescue Octokit::Unauthorized
      false
    end

    def authorize_oauth
      puts "\nPlease enter your github credentials"
      username = request_input('  username: ')
      password = request_input('  password: ', hidden: true)
      mfa_token = request_input('  2FA token: ')
      client = Octokit::Client.new(login: username, password: password)

      # See if we have already authorized a token. If we do, we will need to delete it
      auth = client.authorizations(headers: {'X-GitHub-OTP' => mfa_token}).find { |item| item[:app][:name] == AUTHORIZATION_NAME }
      client.delete_authorization(auth[:id], headers: {'X-GitHub-OTP' => mfa_token}) if auth

      # Otherwise create the new authorization
      oauth_token = client.create_authorization(scopes: SCOPES, note: AUTHORIZATION_NAME, headers: {'X-GitHub-OTP' => mfa_token})

      # Store the new oauth information in AWS
      user = ENV.fetch('USER') # This should error if the user variable doesn't exist
      personal_key_id = Aws::SSM::Client.new.get_parameter(name: "/local/#{user}/kms/id", with_decryption: true).parameter.value
      Aws::SSM::Client.new.put_parameter(
        name: "/local/#{user}/github/oauth_token",
        value: oauth_token[:token],
        type: 'SecureString',
        key_id: personal_key_id,
        overwrite: true
      )
    rescue Octokit::Unauthorized => e
      puts "Login information was incorrect: #{e.message}"
      retry
    end

    def request_input(message, hidden: false)
      print message
      if hidden
        answer = $stdin.noecho(&:gets).chomp
        puts
      else
        answer = $stdin.gets.chomp
      end
      answer
    end

    def to_s
      '#<Github Client>'
    end

    def inspect
      '#<Github Client>'
    end
  end
end
