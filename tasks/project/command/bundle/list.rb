require_relative '../rvm/exec'
require_relative '../bundle'

class ::Project
  class Command
    class Bundle < Rvm::Exec
      class List < Bundle
        def bundle_command
          'list'
        end
      end
    end
  end
end
