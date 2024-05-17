require 'fileutils'
require_relative 'rvm/exec'
require_relative 'bundle/install'
require_relative 'bundle/update'
require_relative 'bundle/list'
require_relative 'bundle/force'

class ::Project
  class Command
    class Bundle < Rvm::Exec
      def initialize(repo, env, logger)
        super
        @bundle_root = env.bundle_root
        rubies.each { |ruby| bundle_path(ruby).mkpath }
      end

      def before
        super
        make_gemfile
      end

      def executable?
        !ignored? && repo.installable?
      end

      def command
        "#{super} \"#{environment} bundle #{bundle_command} #{options} #{verbosity}\""
      end

      def action
        "#{super} bundle #{bundle_command}"
      end

      def environment
        "BUNDLE_PATH='#{bundle_path(ruby)}' BUNDLE_GEMFILE='#{gemfile}'"
      end

      def bundle_path(ruby)
        @bundle_root.join(ruby)
      end

      def gemfile
        "Gemfile.#{ruby}"
      end

      def bundled?
        working_dir.join("Gemfile.#{ruby}.lock").file?
      end

      def make_gemfile
        return if working_dir.join(gemfile).file?

        master = working_dir.join(master_gemfile)
        log "cp #{master} #{gemfile}"
        return if pretend?

        FileUtils.cp(master, gemfile)
      end

      def master_gemfile
        'Gemfile'
      end

      def options
        nil
      end

      def explanation
        if ignored?
          "because it's ignored"
        elsif !repo.installable?
          "because it's missing a Gemfile"
        else
          'reason unknown'
        end
      end
    end
  end
end
