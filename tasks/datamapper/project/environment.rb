require_relative '../../project'
require_relative '../../project/environment'

module DataMapper
  class Project < ::Project
    class Environment < ::Project::Environment
      attr_reader :available_adapters

      def initialize(project_name, options)
        super
        @available_adapters ||= ENV['DM_DEV_ADAPTERS'] ? normalize(ENV['DM_DEV_ADAPTERS']) : default_available_adapters
        @adapters ||= options[:adapters] || (ENV['ADAPTERS'] ? normalize(ENV['ADAPTERS']) : default_adapters)
      end

      def default_available_adapters
        default_adapters
      end

      def default_adapters
        %w(in_memory yaml sqlite postgres mysql)
      end

      def default_excluded
        %w(dm-oracle-adapter dm-sqlserver-adapter)
      end

      def adapters(repo)
        specific_adapters = @adapters.select { |adapter| repo.name =~ /#{adapter}/ }
        specific_adapters.empty? ? @adapters : specific_adapters
      end
    end
  end
end
