require_relative '../../project'
require_relative '../../../project/command/bundle/list'
require_relative '../../project/bundle/manipulation'
require_relative '../../project/bundle'

module DataMapper
  class Project < ::Project
    module Bundle
      class List < ::Project::Command::Bundle::List
        include DataMapper::Project::Bundle::Manipulation, DataMapper::Project::Bundle
      end
    end
  end
end
