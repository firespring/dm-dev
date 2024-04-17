require 'pathname'
require_relative 'metadata'
require_relative 'repository'

class ::Project
  class Repositories
    include Enumerable

    def initialize(root, user, repos, excluded_repos)
      @root = root
      @user = user
      @repos = repos
      @excluded_repos = excluded_repos
      @metadata = Metadata.new(@root, @user)
      @repositories = selected_repositories.map { |repo| Repository.new(@root, repo) }
    end

    def each(&block)
      @repositories.each(&block)
    end

    def add(name, url)
      if @metadata.include?(url)
        puts "#{url} is already managed by dm-dev"
      else
        @metadata.repositories << Struct.new(:name, :url).new(name, url)
        @metadata.save
      end
    end

    private def selected_repositories
      if use_current_directory?
        @metadata.repositories.select { |repo| managed_repo?(repo) }
      else
        @metadata.repositories.select { |repo| include_repo?(repo) }
      end
    end

    private def managed_repo?(repo)
      repo.name == relative_path_name
    end

    private def include_repo?(repo)
      if @repos
        !excluded_repo?(repo) && (include_all? || @repos.include?(repo.name))
      else
        !excluded_repo?(repo)
      end
    end

    private def excluded_repo?(repo)
      @excluded_repos.include?(repo.name)
    end

    private def use_current_directory?
      @repos.nil? && inside_available_repo? && !include_all?
    end

    private def inside_available_repo?
      @metadata.repositories.map(&:name).include?(relative_path_name)
    end

    private def include_all?
      explicitly_specified = @repos.respond_to?(:each) && @repos.count == 1 && @repos.first == 'all'
      if inside_available_repo?
        explicitly_specified
      else
        @repos.nil? || explicitly_specified
      end
    end

    private def relative_path_name
      Pathname(Dir.pwd).relative_path_from(@root).to_s
    end
  end
end
