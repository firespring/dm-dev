require_relative '../../project'
require_relative 'bundle/manipulation'
require_relative 'bundle/install'
require_relative 'bundle/update'
require_relative 'bundle/list'

module DataMapper
  class Project < ::Project
    module Bundle
      # def environment
      #   "#{super} #{support_lib}"
      # end

      def support_lib
        (ruby == '1.8.6') ? 'EXTLIB="true"' : ''
      end

      def adapters(repo)
        env.adapters(repo).join(' ')
      end

      def ignored_repos
        %w(dm-dev data_mapper datamapper.github.com rails_datamapper dm-rails dm-do-adapter)
      end

      def timeout
        2
      end

      def environment
        "#{super} SOURCE=path"
      end
    end
  end
end
