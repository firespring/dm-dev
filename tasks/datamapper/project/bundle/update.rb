require_relative '../../project'
require_relative '../../../project/command/bundle/update'
require_relative '../../project/bundle/manipulation'
require_relative '../../project/bundle'

module DataMapper
  class Project < ::Project
    module Bundle
      class Update < ::Project::Command::Bundle::Update
        include DataMapper::Project::Bundle::Manipulation, DataMapper::Project::Bundle
      end
    end
  end
end
