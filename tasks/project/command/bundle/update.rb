require_relative '../rvm/exec'
require_relative '../bundle'

class ::Project
  class Command
    class Bundle < Rvm::Exec
      class Update < Bundle
        def bundle_command
          'update'
        end
      end
    end
  end
end
