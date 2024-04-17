require 'thor'
require_relative '../../../project'
require_relative 'common_options'

module DataMapper
  class Project < ::Project
    class Tasks < ::Thor
      class Bundle < ::Thor
        namespace 'dm:bundle'

        include CommonOptions

        desc 'install', 'Bundle the DM repositories'
        def install
          DataMapper::Project.bundle_install(options)
        end

        desc 'update', 'Update the bundled DM repositories'
        def update
          DataMapper::Project.bundle_update(options)
        end

        desc 'list', 'List the bundle content'
        def list
          DataMapper::Project.bundle_list(options)
        end

        desc 'force', 'Force re-bundling by removing all Gemfile.platform and Gemfile.platform.lock files'
        def force
          DataMapper::Project.bundle_force(options)
        end
      end
    end
  end
end
