require_relative 'project/command'
require_relative 'project/environment'
require_relative 'project/github'
require_relative 'project/logger'
require_relative 'project/metadata'
require_relative 'project/repositories'
require_relative 'project/repository'
require_relative 'project/utils'

class ::Project
  def self.command_names
    %w(sync bundle:install bundle:update bundle:list bundle:force gem:install gem:uninstall spec release implode status list ci)
  end

  def self.command_name(name)
    command_fragments(name).join('_')
  end

  def self.command_class_name(name)
    command_fragments(name).map(&:capitalize).join('::')
  end

  def self.command_fragments(name)
    name.split(':').map { |fragment| fragment }
  end

  command_names.each do |name|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def self.#{command_name(name)}(options = {})
        new(options).send(:#{command_name(name)})
      end

      def #{command_name(name)}

        start = Time.now if env.benchmark?

        self.class.invoke :before, '#{command_name(name)}', env, repos
        @repos.each do |repo|
          @logger.progress!
          results[repo.name] = command_class('#{name}').new(repo, env, @logger).run
        end
        self.class.invoke :after, '#{command_name(name)}', env, repos

        if env.benchmark?

          elapsed = (Time.now - start).to_i
          message = "Finished 'dm:#{name}' in \#{formatted_time(elapsed)}"

          puts
          puts '-' * message.length
          puts message
          puts '-' * message.length
        end

        results
      end
    RUBY
  end

  attr_reader :env, :root, :repos, :options, :results

  attr_accessor :commands

  def initialize(options = {})
    @options  = options
    @env      = environment_class.new('datamapper', @options)
    @root     = @env.root
    @repos    = Repositories.new(@root, @env.github_user, @env.included, @env.excluded + excluded_repos)
    @logger   = Logger.new(@env, @repos.count)
    @commands = {}
    @results  = {}
  end

  def environment_class
    Environment
  end

  def command_class(name)
    return commands[name] if commands[name]

    Utils.full_const_get(self.class.command_class_name(name), Command)
  end

  def self.before(command_name, &block)
    ((@before ||= {})[command_name] ||= []) << block
  end

  def self.after(command_name, &block)
    ((@after ||= {})[command_name] ||= []) << block
  end

  def self.invoke(kind, name, *args)
    hooks = instance_variable_get("@#{kind}")
    return unless hooks && hooks[name]

    hooks[name].each { |hook| hook.call(*args) }
  end

  def formatted_time(time)
    hours   = (time / 3600).to_i
    minutes = ((time / 60) - (hours * 60)).to_i
    seconds = (time - ((minutes * 60) + (hours * 3600)))

    format('%02d:%02d:%02d', hours, minutes, seconds)
  end
end
