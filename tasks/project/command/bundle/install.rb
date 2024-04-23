require_relative '../rvm/exec'
require_relative '../bundle'

class ::Project
  class Command
    class Bundle < Rvm::Exec
      class Install < Bundle
        def bundle_command
          # @TODO: '; pwd; gem info | grep rspec' is here for debugging an issue. Remove it when finished
          'install; pwd; gem info | grep rspec'
        end
      end
    end
  end
end
