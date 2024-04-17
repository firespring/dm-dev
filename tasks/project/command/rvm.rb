require_relative '../command'

class ::Project
  class Command
    class Rvm < Command
      attr_reader :rubies

      def initialize(repo, env, logger)
        super
        @rubies = env.rubies
      end

      def command
        "rvm #{rubies.join(',')} #{verbose? ? '--verbose' : ''}"
      end
    end
  end
end
