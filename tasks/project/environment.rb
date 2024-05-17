require 'pathname'

class ::Project
  class Environment
    attr_reader :project_name, :github_user, :options, :root, :included, :excluded, :rubies, :bundle_root, :gemset, :command_options

    # rubocop:disable Metrics/CyclomaticComplexity
    def initialize(project_name, options)
      @project_name = project_name
      @github_user = ENV.fetch('GITHUB_USER', 'datamapper')
      @options         = options
      @root            = Pathname(@options[:root] || ENV['DM_DEV_ROOT'] || Dir.pwd).expand_path
      @bundle_root     = Pathname(@options[:bundle_root] || ENV['DM_DEV_BUNDLE_ROOT'] || @root.join(default_bundle_root))
      @rubies          = @options[:rubies] || (ENV['DM_DEV_RUBIES'] ? normalize(ENV['DM_DEV_RUBIES']) : default_rubies)
      @included        = @options[:include] || (ENV['DM_DEV_INCLUDE'] ? normalize(ENV['DM_DEV_INCLUDE']) : default_included)
      @excluded        = @options[:exclude] || (ENV['DM_DEV_EXCLUDE'] ? normalize(ENV['DM_DEV_EXCLUDE']) : default_excluded)
      @gemset          = @options[:gemset] ||  ENV.fetch('DM_DEV_GEMSET', nil)
      @verbose         = @options[:verbose] || (ENV['VERBOSE'] == 'true')
      @silent          = @options[:silent] || (ENV['SILENT'] == 'true')
      @pretend         = @options[:pretend] || (ENV['PRETEND'] == 'true')
      @benchmark       = @options[:benchmark] || (ENV['BENCHMARK'] == 'true')
      @command_options = @options[:command_options] || nil
      @collect_output  = @options[:collect_output] || false
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def default_bundle_root
      'DM_DEV_BUNDLE_ROOT'
    end

    def default_included
      nil # means all
    end

    def default_excluded
      [] # overwrite in subclasses
    end

    def default_rubies
      %w(2.7.8 3.2.2)
    end

    def verbose?
      @verbose
    end

    def silent?
      @silent
    end

    def pretend?
      @pretend
    end

    def benchmark?
      @benchmark
    end

    def collect_output?
      @collect_output
    end

    private def normalize(string)
      string.gsub(',', ' ').split
    end
  end
end
