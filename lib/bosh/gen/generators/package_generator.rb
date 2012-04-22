require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class PackageGenerator < Thor::Group
      include Thor::Actions

      argument :name
      argument :dependencies, :type => :array
      argument :files, :type => :array
      
      def self.source_root
        File.join(File.dirname(__FILE__), "package_generator", "templates")
      end
      
      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end
      
      def check_name
        raise Thor::Error.new("'#{name}' is not a vaild BOSH id") unless name.bosh_valid_id?
      end
      
      def warn_missing_dependencies
        dependencies.each do |d|
          raise Thor::Error.new("dependency '#{d}' is not a vaild BOSH id") unless d.bosh_valid_id?
          unless File.exist?(File.join("packages", d))
            say_status "warning", "missing dependency '#{d}'", :yellow
          end
        end
      end
      
      def packaging
        create_file package_dir("packaging") do
          <<-SHELL.gsub(/^\s{10}/, '')
          # abort script on any command that exit with a non zero value
          set -e
          
          SHELL
        end

        create_file package_dir("pre_packaging") do
          <<-SHELL.gsub(/^\s{10}/, '')
          # abort script on any command that exit with a non zero value
          set -e
          
          SHELL
        end
      end

      def package_specification
        config = { "name" => name, "dependencies" => dependencies, "files" => filenames }
        create_file package_dir("spec"), YAML.dump(config)
      end
      
      def copy_src_files
        files.each do |f|
          copy_file File.expand_path(f), src_dir(File.basename(f))
        end
      end
      
      private
      def filenames
        files.map {|f| File.basename(f) }
      end
      
      def package_dir(path)
        File.join("packages", name, path)
      end

      def src_dir(path)
        File.join("src", name, path)
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
