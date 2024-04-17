require 'addressable/uri'

class ::Project
  class Repository
    attr_reader :path, :name, :uri

    def initialize(root, repo)
      @name = repo.name
      @path = root.join(@name)
      @uri  = Addressable::URI.parse(repo.url)
    end

    def installable?
      path.join('Gemfile').file?
    end
  end
end
