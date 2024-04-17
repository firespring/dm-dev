require 'thor'
require_relative '../../../project'
require_relative 'common_options'

module DataMapper
  class Project < ::Project
    class Tasks < ::Thor
      class Gem < ::Thor
        namespace 'dm:gem'

        include CommonOptions

        class_option :gemset, type: :string, aliases: '-g', desc: 'The rvm gemset to install the gems to'

        desc 'install', 'Install all included gems into the specified rubies'
        def install
          DataMapper::Project.gem_install(options)
        end

        desc 'uninstall', 'Uninstall all included gems from the specified rubies'
        def uninstall
          DataMapper::Project.gem_uninstall(options)
        end
      end
    end
  end
end
