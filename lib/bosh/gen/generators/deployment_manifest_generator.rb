require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class DeploymentManifestGenerator < Thor::Group
      include Thor::Actions

      argument :name
      argument :release_path
      argument :ip_addresses
      argument :flags, :type => :hash

      def check_release_path_is_release
        unless File.exist?(release_path)
          raise Thor::Error.new("target path '#{release_path}' doesn't exist")
        end
        FileUtils.chdir(release_path) do
          unless File.exist?("jobs") && File.exist?("packages")
            raise Thor::Error.new("target path '#{release_path}' is not a BOSH release project")
          end
        end
      end

      # Create a deployment manifest (initially for AWS only)
      def create_deployment_manifest
        cloud_properties = { "instance_type" => "m1.small" }
        manifest = Bosh::Gen::Models::DeploymentManifest.new(name, "DIRECTOR_UUID", cloud_properties)
        manifest.jobs = job_manifests(ip_addresses)
        create_file manifest_file_name, manifest.to_yaml, :force => flags[:force]
      end

      private
      def jobs_dir(path = "")
        File.join(release_path, "jobs", path)
      end

      # Whether +name+ contains .yml suffix or nor, returns a .yml filename for manifest to be generated
      def manifest_file_name
        basename = name.gsub(/\.yml/, '') + ".yml"
      end
      
      def job_manifests(ip_addresses)
        detect_jobs.map do |job_name|
          {
            "name" => job_name
          }
        end
      end
      
      # Return list of job names in this release based on the contents of jobs/* folder
      def detect_jobs
        Dir["jobs/*"].map {|job_path| File.basename(job_path) }
      end

    end
  end
end
