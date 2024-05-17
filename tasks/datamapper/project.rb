require 'fileutils'
require_relative '../project'
require_relative 'project/environment'
require_relative 'project/bundle/update'
require_relative 'project/bundle/list'
require_relative 'project/spec'
require_relative 'project/tasks'

module DataMapper
  class Project < ::Project
    def initialize(options = {})
      super
      commands['bundle:install'] = DataMapper::Project::Bundle::Install
      commands['bundle:update'] = DataMapper::Project::Bundle::Update
      commands['bundle:list'] = DataMapper::Project::Bundle::List
      commands['spec'] = DataMapper::Project::Spec
    end


    def environment_class
      DataMapper::Project::Environment
    end

    def excluded_repos
      %w(dm-more)
    end

    before 'implode' do |env, _repos|
      FileUtils.rm_rf env.bundle_root if env.included.nil? && !env.pretend?
    end
  end
end
