require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class DeploymentManifestGenerator < Thor::Group
      include Thor::Actions

      argument :name
      argument :release_path
      argument :director_uuid
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
        cloud_properties = { "instance_type" => "m1.small", "availability_zone" => "us-east-1e" }
        cloud_properties[:persistent_disk] = flags[:disk] if flags[:disk]
        manifest = Bosh::Gen::Models::DeploymentManifest.new(name, director_uuid, release_properties, cloud_properties)
        manifest.jobs = job_manifests(ip_addresses)
        create_file manifest_file_name, manifest.to_yaml, :force => flags[:force]
      end

      private
      def release_detector
        @release_detector ||= Bosh::Gen::Models::ReleaseDetection.new(release_path)
      end
      
      # Whether +name+ contains .yml suffix or nor, returns a .yml filename for manifest to be generated
      def manifest_file_name
        basename = name.gsub(/\.yml/, '') + ".yml"
      end
      
      def job_manifests(ip_addresses)
        jobs = detect_jobs.map do |job_name|
          {
            "name" => job_name
          }
        end
        jobs.first["static_ips"] = ip_addresses if ip_addresses && ip_addresses.size > 0
        jobs
      end
      
      # Return list of job names
      def detect_jobs
        release_detector.latest_dev_release_job_names
      end
      
      # The "release" aspect of the manifest, which has two keys: name, version
      def release_properties
        release_detector.latest_dev_release_properties
      end
    end
  end
end
