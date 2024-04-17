require 'yaml'
require_relative '../source'

class ::Project
  class Metadata
    class Source
      class Yaml < Source
        def load
          YAML.load(File.open(filename))['repositories'].map do |repo|
            Struct.new(:name, :url).new(repo['name'], repo['url'])
          end
        end
      end
    end
  end
end
