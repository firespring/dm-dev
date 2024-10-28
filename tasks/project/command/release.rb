require 'fileutils'
require_relative '../command'

class ::Project
  class Command
    class Release < Command
      def run
        FileUtils.cd(working_dir) do
          clean_repository()
          log(working_dir)
          log(command)
          system(command) unless pretend?
        end
      end

      def command
        'rake release'
      end

      def action
        'Releasing'
      end

      def clean_repository()
        system('git clean -dfx --exclude=*.gem')
      end
    end
  end
end
