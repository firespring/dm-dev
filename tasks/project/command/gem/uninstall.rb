require_relative '../rvm'
require_relative '../gem'

class ::Project
  class Command
    class Gem < Rvm
      class Uninstall < Gem
        def command
          "#{super} do gem uninstall #{repo.name} --version #{version}"
        end

        def action
          'Uninstalling'
        end
      end
    end
  end
end
