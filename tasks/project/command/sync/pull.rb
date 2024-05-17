require_relative '../../command'
require_relative '../sync'

class ::Project
  class Command
    class Sync < Command
      class Pull < Sync
        def command
          "git checkout master #{verbosity}; git pull --rebase #{verbosity}"
        end

        def action
          'Pulling'
        end

        def target_revision
          env.options[:revision]
        end

        def revision
          `git rev-parse HEAD`.chomp!
        end

        def skip?
          target_revision == revision
        end
      end
    end
  end
end
