require 'thor'
require_relative '../../project'
require_relative '../../ci/client'

module DataMapper
  class Project < ::Project
    class Tasks < ::Thor
      class Ci < ::Thor
        namespace 'dm:ci'

        desc 'client', 'Start a client that fetches and executes DataMapper CI jobs'
        method_option :sleep_period, type: :numeric, aliases: '-w', desc: 'When no jobs are available, sleep that many seconds before asking again'
        method_option :stop_when_done, type: :boolean, aliases: '-x', desc: 'Stop when no more jobs are available'
        method_option :status, type: :array, aliases: '-s', desc: 'A list of statuses to accept for new jobs (defaults to "modified" and "skipped")'

        def client
          DataMapper::CI::Client.new(options).run
        end
      end
    end
  end
end
