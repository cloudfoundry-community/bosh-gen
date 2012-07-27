require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class ExtractJobGenerator < Thor::Group
      include Thor::Actions

      argument :source_release_path
      argument :source_job_name
      argument :job_name
      
      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end
      
      def using_source_release_for_templates
        source_paths << File.join(source_release_path)
      end

      def copy_job_dir
        directory "jobs/#{source_job_name}", "jobs/#{job_name}"
      end
      
      def detect_dependent_packages
        @packages = YAML.load_file(job_dir("spec"))["packages"]
      end
      
      def copy_dependent_packages
        @packages.each {|package| directory "packages/#{package}"}
      end

      def copy_dependent_sources
        @blobs = false
        @packages.each do |package|
          if File.exist?(File.join(source_release_path, "src", package))
            directory "src/#{package}"
          end
          if File.exist?(File.join(source_release_path, "blobs", package))
            directory "blobs/#{package}"
            @blobs = true
          end
        end
      end
      
      def readme
        if @blobs
          say_status "readme", "Upload blobs with 'bosh upload blobs'"
        end
      end
      
      private
      def job_dir(path="")
        File.join("jobs", job_name, path)
      end
      
    end
  end
end
