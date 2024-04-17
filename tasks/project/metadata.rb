require_relative 'metadata/source'

class ::Project
  class Metadata
    attr_reader :root, :name, :repositories, :filename

    def self.load(root, name)
      new(root, name).repositories
    end

    def initialize(root, name)
      @root = root
      @name = name
      @filename = @root.join(config_file_name)
      @source       = Source.new(@filename, name)
      @repositories = @source.load
    end

    def save
      @source.save(repositories)
      self
    end

    def config_file_name
      'dm-dev.yml'
    end

    def include?(url)
      repositories.map(&:url).include?(url)
    end
  end
end
