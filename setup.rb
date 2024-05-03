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
          @included_repos_actions.call(repo) do |_config, github_repo, dest_path, is_repo|
            next unless is_repo

            Dir.chdir(dest_path) do
              unless clean?(dest_path)
                puts "#{github_repo} working directory is dirty. Unable to checkout #{branch_name}"
                next
              end

              if create
                # @todo this probably needs some error handling or checking to see if the branch already exists
                puts "Create and Checkout branch: #{branch_name}"
                `git checkout -b #{branch_name}; git push -u origin`
              else
                puts "Checkout branch: #{branch_name}"
                `git pull; git checkout #{branch_name}`
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

    def clean?(path)
      `cd #{path}; git status --porcelain`.empty?
    end

    def current_branch(path)
      `cd #{path}; git rev-parse --abbrev-ref HEAD`.strip
    end

    def pull_included_repos
      Dir.chdir(config.dev_root) do
        config.include_repos.each do |repo|
          @included_repos_actions.call(repo) do |_config, github_repo, dest_path, is_repo|
            next unless is_repo

            Dir.chdir(dest_path) do
              branch = current_branch(dest_path)
              if clean?(dest_path)
                puts "Pull branch: #{branch} for #{github_repo}"
                `git pull`
              else
                puts "Branch #{branch} is dirty. Unable to pull for #{github_repo}"
                next
              end
            end
          end
        end
      end
    end
  end
end

def main(_args)
  opts = Optimist.options do
    opt :clone, 'Clone all datamapper included repos into DM_DEV_ROOT'
    opt :checkout, 'Checkout specified branch for all included repos', type: String, default: 'master'
    opt :create, "Create the checked out branch if it doesn't exist"
    opt :pull, 'Pull specified branch'
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
    in pull: true
      git_commands.pull_included_repos
    end
  end
end

main $ARGV
