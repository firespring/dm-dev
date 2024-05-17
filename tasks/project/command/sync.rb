require_relative '../command'
require_relative 'sync/clone'
require_relative 'sync/pull'

class ::Project
  class Command
    class Sync < Command
      def self.new(repo, env, logger)
        return super unless self == Sync

        if env.root.join(repo.name).directory?
          Pull.new(repo, env, logger)
        else
          Clone.new(repo, env, logger)
        end
      end
    end
  end
end
