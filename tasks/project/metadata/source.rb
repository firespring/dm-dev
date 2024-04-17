require 'yaml'
require_relative 'source/github'
require_relative 'source/yaml'

class ::Project
  class Metadata
    class Source
      attr_reader :filename

      def self.new(filename, *args)
        return super if self < Source

        if filename.file?
          Yaml.new(filename)
        else
          Github.new(filename, *args)
        end
      end

      def initialize(filename)
        @filename = filename
      end

      def load
        raise NotImplementedError
      end

      def save(repositories)
        File.write(filename, YAML.dump({
                                         'repositories' => repositories.map { |repo| {'name' => repo.name, 'url' => repo.url} }
                                       }))
        repositories
      end
    end
  end
end
