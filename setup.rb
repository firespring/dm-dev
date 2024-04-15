#!/usr/bin/env ruby

require 'dotenv'
require 'git'
require 'optimist'
require 'pathname'

module DatamapperProject
  class Config
    attr_reader :branch_name, :dev_root, :github_base_uri, :include_repos

    def initialize
      config = '.env'
      Dotenv.load(config)
      @branch_name = ENV.fetch('GIT_BRANCH', 'master')
      @include_repos = ENV.fetch('DM_DEV_INCLUDE', '').split
      @dev_root = File.expand_path('..', __dir__.to_s)
      @github_base_uri = 'github.com:firespring/'
    end
  end

  class Git
    attr_reader :config

    def initialize(config_obj)
      @config = config_obj
      @included_repos_actions = proc do |repo, &blk|
        dest_path = File.expand_path(repo, config.dev_root)
        is_repo = git_repo? dest_path

        # @TODO: verify what happens if GIT_BRANCH doesn't exist on the remote
        github_repo = "#{config.github_base_uri}#{repo}.git"

        # Block to take action on the given repository
        blk.call(config, github_repo, dest_path, is_repo)
      end
    end

    def checkout(branch_name, create: false)
      Dir.chdir(config.dev_root) do
        config.include_repos.each do |repo|
          @included_repos_actions.call(repo) do |_config, _github_repo, dest_path, is_repo|
            next unless is_repo

            Dir.chdir(dest_path) do
              if create
                # @todo this probably needs some error handling or checking to see if the branch already exists
                puts "Create and Checkout branch: #{branch_name}"
                `git checkout -b #{branch_name}; git push -u origin`
              else
                puts "Checkout branch: #{branch_name}"
                `git checkout #{branch_name}`
              end
            end
          end
        end
      end
    end

    def clone_included_repos
      Dir.chdir(config.dev_root) do
        config.include_repos.each do |repo|
          @included_repos_actions.call(repo) do |config, github_repo, dest_path, is_repo|
            next if is_repo

            uri = Pathname("git@#{github_repo}")
            puts "GIT CLONE: git@#{github_repo} at Branch: #{config.branch_name} into #{dest_path}"
            ::Git.clone(uri, dest_path, branch: config.branch_name)
          end
        end
      end
    end

    def git_repo?(path)
      return false unless Dir.exist?(path)
      return false if Dir.empty?(path)

      `$(cd #{path}; git rev-parse --is-inside-work-tree 2>/dev/null)`
    end
  end
end

def main(_args)
  opts = Optimist.options do
    opt :clone, 'Clone all datamapper included repos into DM_DEV_ROOT'
    opt :checkout, 'Checkout specified branch for all included repos', type: String, default: 'master'
    opt :create, "Create the checked out branch if it doesn't exist"
  end

  config = DatamapperProject::Config.new
  git_commands = DatamapperProject::Git.new(config)

  if opts[:checkout_given] && opts[:create]
    git_commands.checkout(opts[:checkout], create: true)
  else
    case opts
    in clone: true
      git_commands.clone_included_repos
    in checkout_given: true
      git_commands.checkout(opts[:checkout])
    end
  end
end

main $ARGV
