require_relative 'bundle'

class ::Project
  class Command
    class Spec < Bundle
      def run
        if print_matrix?
          puts  "\nh2. %s\n\n"   % repo.name
          puts  '| RUBY  | %s |' % env.adapters(repo).join(' | ')
        end

        super do |ruby|
          print '| %s |' % ruby if print_matrix?

          if block_given?
            yield ruby
          else
            execute
            print format(' %s |', status) if print_matrix?
          end
        end
      end

      def bundle_command
        # @TODO: '; pwd; gem info | grep rspec' is here for debugging an issue. Remove it when finished
        if env.command_options
          "exec spec #{env.command_options.join(' ')}; pwd; gem info | grep rspec"
        else
          'exec rake spec; pwd; gem info | grep rspec'
        end
      end

      def action
        "#{super} Testing"
      end

      def print_matrix?
        executable? && !verbose? && !pretend?
      end

      def suppress_log?
        !executable? || print_matrix?
      end

      def skip?
        target_revision && !clean?
      end

      def target_revision
        env.options[:revision]
      end

      def clean?
        `git status` =~ /working directory clean/
      end
    end
  end
end
