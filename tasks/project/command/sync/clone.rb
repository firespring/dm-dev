require_relative '../../command'
require_relative '../sync'

class ::Project
  class Command
    class Sync < Command
      class Clone < Sync
        def initialize(repo, env, logger)
          super
          @git_uri        = uri.dup
          @git_uri.scheme = 'git'
          return unless env.options[:development]

          @git_uri.to_s.sub!('://', '@').sub!('/', ':')
        end

        def command
          "git clone #{@git_uri}.git #{verbosity}"
        end

        def working_dir
          root
        end

        def action
          'Cloning'
        end
      end
    end
  end
end
