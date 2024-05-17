require_relative 'ci/client'

module DataMapper
  module CI
    SERVICE_URL = ENV['TESTOR_SERVER'] || 'http://localhost:3000'
  end
end
