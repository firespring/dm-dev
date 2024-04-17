require_relative '../../project'
require_relative '../../project/command/spec'

module DataMapper
  class Project < ::Project
    class Spec < ::Project::Command::Spec
      include DataMapper::Project::Bundle

      def before
        DataMapper::Project.bundle_install(env.options.merge(silent: true)) unless bundled?
      end

      def run
        super do |_ruby|
          env.adapters(repo).each do |adapter|
            @adapter = adapter # HACK?

            execute

            print format(' %s |', status) if print_matrix?
          end
          puts if print_matrix?
        end
      end

      def environment
        "#{super} ADAPTER=#{@adapter} TZ=utc"
      end

      def skip?
        !env.available_adapters.include?(@adapter)
      end
    end
  end
end
