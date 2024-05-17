require 'json'
require 'rest_client'
require_relative '../../project'
require_relative '../../ci'

module DataMapper
  module CI
    class Client
      class Job
        attr_reader :id, :platform, :adapter, :library, :revision, :previous_status, :data

        def initialize(data, requested_status, credentials)
          @requested_status = requested_status
          @credentials      = credentials
          @id               = data['id']
          @platform         = data['platform_name']
          @adapter          = data['adapter_name']
          @library          = data['library_name']
          @revision         = data['revision']
          @previous_status  = data['previous_status']
          @data             = data
          @results          = {}
        end

        def run
          @running = true
          if accept
            @results = execute
            report
          end
          @running = false
          @results
        end

        def accept
          response = JSON.parse(RestClient.post("#{CI::SERVICE_URL}/jobs/accept",
                                                {
                                                  id: id,
                                                  status: @requested_status.join(','),
                                                  credentials: @credentials
                                                }))
          config = "job = #{id}, gem = #{library}, platform = #{platform}, adapter = #{adapter}"
          if response['accepted']
            puts "\nACCEPTED: #{config}"
          else
            puts "\nREJECTED: #{config}"
          end
          response['accepted']
        end

        def execute
          permutation = {include: [library], rubies: [platform], adapters: [adapter], revision: revision}
          DataMapper::Project.sync(permutation)
          DataMapper::Project.spec(permutation.merge(verbose: true, collect_output: true))
        end

        def report
          RestClient.post("#{CI::SERVICE_URL}/jobs/report",
                          credentials: @credentials,
                          report: {
                            job_id: id,
                            status: result[:status],
                            output: result[:output],
                            duration: result[:duration],
                            revision: revision
                          })
        end

        def running?
          @running
        end

        def result
          if @results[library]
            @results[library].first # we know that we only get one result back
          else
            {status: 'skipped', output: 'skipped'} # HACK
          end
        end
      end
    end
  end
end
