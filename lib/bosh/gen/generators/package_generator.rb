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

      # Copy the local source files into src/NAME/filename, unless filename
      # already exists as a blob in blobs/NAME/filename.
      def copy_src_files
        files.each do |file_path|
          file_name = File.basename(file_path)
          src_file = src_dir(file_name)
          if File.exist? blob_dir(file_name)
            say "Blob '#{file_name}' exists as a blob, skipping..."
          else
            copy_file File.expand_path(f), src_file
          end
        end
      end
      
      def package_specification
        src_files = files.map {|f| "src/#{name}/#{File.basename(f)}"}
        config = { "name" => name, "dependencies" => dependencies, "files" => src_files }
        create_file package_dir("spec"), YAML.dump(config)
      end
      
      private
      def package_dir(path)
        "packages/#{name}/#{path}"
      end

      def src_dir(path)
        "src/#{name}/#{path}"
      end
      
      def blob_dir(path)
        "blobs/#{name}/#{path}"
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
