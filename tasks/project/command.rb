require_relative 'command/bundle'
require_relative 'command/gem'
require_relative 'command/implode'
require_relative 'command/list'
require_relative 'command/release'
require_relative 'command/rvm'
require_relative 'command/spec'
require_relative 'command/status'
require_relative 'command/sync'

class ::Project
  class Command
    attr_reader :repo, :env, :root, :path, :uri, :logger, :results, :output

    def initialize(repo, env, logger)
      @repo    = repo
      @env     = env
      @root    = @env.root
      @path    = @root.join(@repo.name)
      @uri     = @repo.uri
      @logger  = logger
      @verbose = @env.verbose?
      @results = []
    end

    def before
      # overwrite in subclasses
    end

    def run
      log_directory_change
      FileUtils.cd(working_dir) do
        if block_given?
          yield
        else
          execute
        end
      end
      results
    end

    def after
      # overwrite in subclasses
    end

    def execute
      if executable?
        before
        log(command) unless suppress_log? || skip?
        unless pretend?
          sleep(timeout)
          start_time = Time.now
          shell(command) unless skip?
          duration = (Time.now - start_time).to_i
          @results << {status: status, output: output, duration: duration}
        end
        after
      elsif verbose? && !pretend?
        log(command, "SKIPPED! - #{explanation}")
      end
    end

    def skip?
      false
    end

    def status
      if skip?
        :skipped
      else
        $CHILD_STATUS&.success? ? :pass : :fail
      end
    end

    # overwrite in subclasses
    def command
      raise NotImplementedError
    end

    # overwrite in subclasses
    def executable?
      true
    end

    # overwrite in subclasses
    def suppress_log?
      false
    end

    # overwrite in subclasses
    def explanation
      'reason unknown'
    end

    def log_directory_change
      return unless needs_directory_change? && (verbose? || pretend?)

      log "cd #{working_dir}"
    end

    def needs_directory_change?
      Dir.pwd != working_dir.to_s
    end

    def ignored?
      ignored_repos.include?(repo.name)
    end

    # overwrite in subclasses
    def ignored_repos
      []
    end

    # overwrite in subclasses
    def working_dir
      path
    end

    def verbose?
      @verbose
    end

    def pretend?
      @env.pretend?
    end

    def collect_output?
      env.collect_output?
    end

    def verbosity
      verbose? ? verbose : silent
    end

    # overwrite in subclasses
    def verbose; end

    def silent
      ' > /dev/null 2>&1'
    end

    # overwrite in subclasses
    def timeout
      0
    end

    # overwrite in subclasses
    def action; end

    def log(command = nil, msg = nil)
      logger.log(repo, action, command, msg)
    end

    def shell(command)
      if collect_output?
        @output = `#{command}`
      else
        system(command)
      end
    end
  end
end
