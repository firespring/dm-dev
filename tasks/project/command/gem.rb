require_relative 'rvm'
require_relative 'gem/install'
require_relative 'gem/uninstall'

class ::Project
  class Command
    class Gem < Rvm
      def before
        create_gemset = "rvm gemset create #{env.gemset}"

        log    create_gemset if env.gemset && verbose?
        system create_gemset if env.gemset && !pretend?
      end

      def rubies
        env.gemset ? super.map { |ruby| "#{ruby}@#{env.gemset}" } : super
      end

      def gem
        "#{working_dir.join(repo.name)}-#{version}.gem"
      end

      def gemspec_file
        "#{working_dir.join(repo.name)}.gemspec"
      end

      def version
        return unless File.exist? gemspec_file

        ::Gem::Specification.load(gemspec_file).version
      end
    end
  end
end
