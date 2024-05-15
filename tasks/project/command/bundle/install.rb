require_relative '../rvm/exec'
require_relative '../bundle'

class ::Project
  class Command
    class Bundle < Rvm::Exec
      class Install < Bundle
        def bundle_command
          'install'
        end
      end
    end
  end
end
