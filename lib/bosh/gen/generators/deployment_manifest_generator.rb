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

      def create_root
        self.destination_root = File.expand_path(name, destination_root)
        empty_directory '.'
        FileUtils.cd(destination_root) unless options[:pretend]
      end

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
        cloud_properties = { 
          "instance_type" => "m1.small", 
          "availability_zone" => "us-east-1e"
        }
        cloud_properties["persistent_disk"] = flags[:disk] if flags[:disk]
        cloud_properties["static_ips"] = ip_addresses
        director_uuid = Bosh::Gen::Models::BoshConfig.new.target_uuid
        manifest = Bosh::Gen::Models::DeploymentManifest.new(
          name, director_uuid, release_properties, cloud_properties)
        manifest.jobs = job_manifests
        create_file manifest_file_name, manifest.to_yaml, :force => flags[:force]
      end

      def setup_bosh_deployment_target
        run "bosh deployment #{manifest_file_name}"
      end

      private
      def release_detector
        @release_detector ||= Bosh::Gen::Models::ReleaseDetection.new(release_path)
      end
      
      # Whether +name+ contains .yml suffix or nor, returns a .yml filename for manifest to be generated
      def manifest_file_name
        basename = "manifest.yml"
      end
      
      def job_manifests
        jobs = detect_jobs.map do |job_name|
          {
            "name" => job_name
          }
        end
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
