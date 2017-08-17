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
          file_globs = YAML.load_file(spec)["files"]

          file_globs.each do |file_glob|
            source_files = Dir.glob(File.join(source_release_path, "src", file_glob))
            source_files.each do |source_path|
              target_path = source_path.scan(%r{/blobs/(.*)}).flatten.first
              copy_file(File.join("src", target_path))
            end
          end

          file_globs.each do |file_glob|
            source_files = Dir.glob(File.join(source_release_path, "blobs", file_glob))
            source_files.each do |source_path|
              target_path = source_path.scan(%r{/blobs/(.*)}).flatten.first
              `bosh add-blob "#{source_path}" "#{target_path}"`
              say_status "add-blob", target_path
              @blobs = true
            end
          end
        end
      end

      def readme
        if @blobs
          say_status "readme", "Upload blobs with 'bosh upload-blobs'"
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
