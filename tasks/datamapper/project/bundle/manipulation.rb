require_relative '../../project'

module DataMapper
  class Project < ::Project
    module Bundle
      module Manipulation
        def environment
          "#{super} ADAPTERS='#{adapters(repo)}'"
        end
      end
    end
  end
end
