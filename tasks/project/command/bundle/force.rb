require_relative '../rvm/exec'
require_relative '../../command'

class ::Project
  class Command
    class Bundle < Rvm::Exec
      class Force < ::Project::Command
        def command
          'rm Gemfile.*'
        end
      end
    end
  end
end
