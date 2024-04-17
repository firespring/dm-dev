require_relative '../../project'
require_relative '../../../project/command/bundle/install'
require_relative '../../project/bundle/manipulation'
require_relative '../../project/bundle'

module DataMapper
  class Project < ::Project
    module Bundle
      class Install < ::Project::Command::Bundle::Install
        include DataMapper::Project::Bundle::Manipulation, DataMapper::Project::Bundle

        def options
          ''
        end
      end
    end
  end
end
