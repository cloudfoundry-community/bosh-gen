require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class JobGenerator < Thor::Group
      include Thor::Actions

      argument :job_name
      argument :dependencies, :type => :array
      argument :purpose

      def self.source_root
        File.join(File.dirname(__FILE__), "job_generator", "templates")
      end

      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end

      def check_name
        raise Thor::Error.new("'#{job_name}' is not a valid BOSH id") unless job_name.bosh_valid_id?
      end

      def check_purpose
        unless valid_purposes.include?(purpose)
          raise Thor::Error.new("'#{purpose}' is not a valid job purpose of #{valid_purposes.inspect}")
        end
      end

      def warn_missing_dependencies
        dependencies.each do |d|
          raise Thor::Error.new("dependency '#{d}' is not a valid BOSH id") unless d.bosh_valid_id?
          unless File.exist?(File.join("packages", d))
            say_status "warning", "missing dependency '#{d}'", :yellow
          end
        end
      end

      # copy the thor template files into the bosh release to be bosh templates
      # that's right, templates (.tt) can become templates (.erb)
      def template_files
        generator_job_templates_path = File.join(self.class.source_root, "jobs/%job_name%_#{purpose}")
        directory "jobs/%job_name%_#{purpose}", "jobs/#{job_name}"

        # build a hash of { 'bin/webapp_ctl.erb' => 'bin/webapp_ctl', ...} used in spec
        @template_files = {}
        FileUtils.chdir(File.join(generator_job_templates_path, "templates")) do
          `ls */*`.split("\n").each do |template_file|
            # clean up thor name convention
            template_file.gsub!("%job_name%", job_name)
            template_file.gsub!(".tt", "")
            # strip erb from target file
            target_template_file = template_file.gsub(/.erb/, '')

            @template_files[template_file] = target_template_file
          end
        end
      end

      private
      def filenames
        files.map {|f| File.basename(f) }
      end

      def job_dir(path)
        File.join("jobs", job_name, path)
      end

      def valid_purposes
        %w[bpm simple]
      end

      # Run a command in git.
      #
      # ==== Examples
      #
      #   git :init
      #   git :add => "this.file that.rb"
      #   git :add => "onefile.rb", :rm => "badfile.cxx"
      #
      def git(commands={})
        if commands.is_a?(Symbol)
          run "git #{commands}"
        else
          commands.each do |cmd, options|
            run "git #{cmd} #{options}"
          end
        end
      end
    end
  end
end
