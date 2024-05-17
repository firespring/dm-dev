require_relative '../../command'
require_relative '../rvm'

class ::Project
  class Command
    class Rvm < Command
      class Exec < Rvm
        attr_reader :ruby

        def run
          super do
            rubies.each do |ruby|
              @ruby = ruby
              if block_given?
                yield(ruby)
              else
                execute
              end
            end
          end
        end

        private def command
          "rvm #{@ruby} exec bash -c"
        end

        private def action
          "[#{@ruby}]"
        end
      end
    end
  end
end
