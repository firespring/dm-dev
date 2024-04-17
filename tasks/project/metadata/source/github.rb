require_relative '../source'
require_relative '../../github'

class ::Project
  class Metadata
    class Source
      class Github < Source
        attr_reader :username

        def initialize(filename, username)
          super(filename)
          @username = username
        end

        def load
          gh = GitHub.new
          dm_repos = gh.client.repositories.select { |r| r.full_name.include?('datamapper') || r.full_name.include?('dm-') }
          save(dm_repos)
        end
      end
    end
  end
end
