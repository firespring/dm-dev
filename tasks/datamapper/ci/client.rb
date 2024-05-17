require 'json'
require 'rest_client'
require_relative '../../project'
require_relative '../ci'
require_relative 'client/job'

module DataMapper
  module CI
    class Client
      def initialize(options)
        @sleep_period     = options[:sleep_period] || ENV['TESTOR_SLEEP_PERIOD'] || 60
        @stop_when_done   = options[:stop_when_done] || ENV['TESTOR_STOP_WHEN_DONE'] || true
        @requested_status = options[:status]         || [] # rely on server defaults
        @previous_jobs    = [] # TODO: remember those
      end

      def run
        loop do
          if (job = next_job)
            job.run
            @previous_jobs << job.id
          elsif @stop_when_done
            exit(0)
          else
            sleep(@sleep_period)
          end
        end
      end

      private def next_job
        job_data = JSON.parse(RestClient.get("#{CI::SERVICE_URL}/jobs/next",
                                             {params: {
                                               previous_jobs: @previous_jobs.join(','),
                                               status: @requested_status.join(',')
                                             }}))
        job_data.empty? ? nil : Client::Job.new(job_data, @requested_status, credentials)
      end

      private def credentials
        {login: testor_login, token: testor_token}
      end

      private def testor_login
        ENV.fetch('TESTOR_LOGIN', nil)
      end

      private def testor_token
        ENV.fetch('TESTOR_TOKEN', nil)
      end
    end
  end
end
