require_relative '../command'

class ::Project
  class Command
    class Implode < Command
      def run
        log    command
        system command unless pretend?
      end

      def command
        "rm -rf #{working_dir} #{verbosity}"
      end

      def action
        'Deleting'
      end
    end
  end
end
