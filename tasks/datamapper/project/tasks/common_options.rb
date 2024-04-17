require 'thor'
require_relative '../../project'

module DataMapper
  class Project < ::Project
    class Tasks < ::Thor
      module CommonOptions
        def self.included(host)
          host.class_eval do
            class_option :root, type: :string, aliases: '-r',
                                desc: 'The directory where all DM source code is stored (overwrites DM_DEV_ROOT)'
            class_option :bundle_root, type: :string, aliases: '-B',
                                       desc: 'The directory where bundler stores all its data (overwrites DM_DEV_BUNDLE_ROOT)'
            class_option :rubies, type: :array, aliases: '-R', desc: 'The rvm ruby interpreters to use with this command (overwrites RUBIES)'
            class_option :include, type: :array, aliases: '-i', desc: 'The DM gems to include with this command (overwrites INCLUDE)'
            class_option :exclude, type: :array, aliases: '-e', desc: 'The DM gems to exclude with this command (overwrites EXCLUDE)'
            class_option :adapters, type: :array, aliases: '-a', desc: 'The DM adapters to use with this command (overwrites ADAPTERS)'
            class_option :pretend, type: :boolean, aliases: '-p', desc: 'Print the shell commands that would get executed'
            class_option :verbose, type: :boolean, aliases: '-v', desc: 'Print the shell commands being executed'
            class_option :silent, type: :boolean, aliases: '-s', desc: "Don't print anything to $stdout"
            class_option :benchmark, type: :boolean, aliases: '-b', desc: 'Print the time the command took to execute'
          end
        end

        def options
          if (index = ARGV.index('--'))
            super.merge(command_options: ARGV.slice(index + 1, ARGV.size - 1))
          else
            super
          end
        end
      end
    end
  end
end
