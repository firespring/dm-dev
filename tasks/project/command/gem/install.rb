require_relative '../rvm'
require_relative '../gem'

class ::Project
  class Command
    class Gem < Rvm
      class Install < Gem
        def command
          "#{super} do gem build #{gemspec_file}; #{super} do gem install #{gem} --no-document"
        end

        def action
          'Installing'
        end
      end
    end
  end
end
