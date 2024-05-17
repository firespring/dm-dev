require 'thor'
require_relative '../../../project'
require_relative '../../project'

module DataMapper
  class Project < ::Project
    class Tasks < ::Thor
      class Meta < ::Thor
        namespace 'dm:meta'

        desc 'list', 'List locally known DM repositories'
        def list
          DataMapper::Project.list
        end

        desc 'add', 'Add a new gem to the list of gems to test'
        method_option :name, type: :string, aliases: '-n', desc: 'The name of the gem to add'
        method_option :url,  type: :string, aliases: '-u', desc: 'The git(hub) repo url that contains the gem to add'

        def add
          DataMapper::Project.new(options).repos.add(options[:name], options[:url])
        end
      end
    end
  end
end
