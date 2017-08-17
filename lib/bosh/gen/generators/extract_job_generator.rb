require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class ExtractJobGenerator < Thor::Group
      include Thor::Actions

      argument :source_job_path

      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end

      def check_job_path_is_valid
        unless File.exist?(source_job_path)
          raise Thor::Error.new("source job path does not exist")
        end
      end

      def check_job_path_is_a_job
        parent_dir = File.basename(File.dirname(source_job_path))
        unless parent_dir == "jobs"
          raise Thor::Error.new("source jobs path is not a BOSH job")
        end
      end

      def check_job_path_within_release
        FileUtils.chdir(source_release_path) do
          unless File.exist?("jobs") && File.exist?("packages")
            raise Thor::Error.new("source job path is not within a BOSH release project")
          end
        end
      end

      def using_source_release_for_templates
        source_paths << File.join(source_release_path)
      end

      def copy_job_dir
        directory "jobs/#{source_job_name}", "jobs/#{target_job_name}", mode: :preserve
      end

      def detect_dependent_packages
        @packages = YAML.load_file(job_dir("spec"))["packages"]
      end

      def copy_dependent_packages
        @packages.each {|package| directory "packages/#{package}"}
      end

      def copy_package_spec_files
        @blobs = false
        @packages.each do |package|
          spec = source_file("packages", package, "spec")
          files = YAML.load_file(spec)["files"]

          files.each do |relative_file|
            if File.exist?(source_file("src", relative_file))
              copy_file "src/#{relative_file}"
            elsif File.exist?(source_file("blobs", relative_file))
              copy_file "blobs/#{relative_file}"
              @blobs = true
            end
          end
        end
      end

      def readme
        if @blobs
          say_status "readme", "Upload blobs with 'bosh upload blobs'"
        end
      end

      private
      def source_release_path
        File.expand_path(File.join(source_job_path, "..", ".."))
      end

      def source_job_name
        File.basename(source_job_path)
      end

      def target_job_name
        source_job_name
      end

      def job_dir(path="")
        File.join("jobs", target_job_name, path)
      end

      def source_file(*path)
        File.join(source_release_path, *path)
      end
    end
  end
end
