require 'thor'
require_relative '../project'
require_relative 'tasks/bundle'
require_relative 'tasks/common_options'
require_relative 'tasks/gem'
require_relative 'tasks/meta'
require_relative 'tasks/ci'

module DataMapper
  class Project < ::Project
    class Tasks < ::Thor
      namespace :dm

      include CommonOptions, Thor::Actions

      def self.source_root
        File.dirname(__FILE__)
      end

      desc 'sync', 'Sync with the DM repositories'
      method_option :development, type: :boolean, aliases: '-d', desc: 'Use the private github clone url if you have push access'
      def sync
        DataMapper::Project.sync(options)
      end

      desc 'spec', 'Run specs for DM gems'
      def spec
        DataMapper::Project.spec(options)
      end

      desc 'release', 'Release all DM gems to rubygems'
      def release
        DataMapper::Project.release(options)
      end

      desc 'implode', 'Delete all DM gems'
      def implode
        return unless implode_confirmed?

        DataMapper::Project.implode(options)
      end

      desc 'status', 'Show git status information'
      def status
        DataMapper::Project.status(options)
      end

      no_commands do
        private def implode_confirmed?
          return true if options[:pretend]

          question = "Are you really sure? This will destroy #{affected_repositories}! (yes)"
          ask(question) == 'yes'
        end

        private def affected_repositories
          included = options[:include]
          if include_all?(included)
            'not only all repositories, but also everything below DM_DEV_BUNDLE_ROOT!'
          else
            "the following repositories: #{included.join(', ')}!"
          end
        end

        private def include_all?(included)
          include_all_implicitly?(included) || include_all_explicitly?(included)
        end

        private def include_all_implicitly?(included)
          included.nil?
        end

        private def include_all_explicitly?(included)
          included.respond_to?(:each) && included.count == 1 && included.first == 'all'
        end
      end
    end
  end
end
