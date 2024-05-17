require_relative '../command'

class ::Project
  class Command
    class List < ::Project::Command
      def run
        log
      end
    end
  end
end
