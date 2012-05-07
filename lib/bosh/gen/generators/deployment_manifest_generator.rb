require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class DeploymentManifestGenerator < Thor::Group
      include Thor::Actions

      argument :name
      argument :release_path
      argument :flags, :type => :hash

      def self.source_root
        File.join(File.dirname(__FILE__), "deployment_manifest_generator", "templates")
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
        initial = YAML.load_file(File.join(self.class.source_root, "initial_deployment_manifest.yml"))
        cloud_properties = { "instance_type" => "m1.small" }
        spec = initial.merge({
          "jobs" => [job_manifest('foobar', ['1.2.3.4', '2.3.4.5'])]
        })
        spec["compilation"]["cloud_properties"] = cloud_properties
        create_file manifest_file_name, YAML.dump(spec), :force => flags[:force]
      end

      private
      def jobs_dir(path = "")
        File.join(release_path, "jobs", path)
      end

      # Whether +name+ contains .yml suffix or nor, returns a .yml filename for manifest to be generated
      def manifest_file_name
        basename = name.gsub(/\.yml/, '') + ".yml"
      end

      def job_manifest(name, ip_addresses = [])
        { "name" => name,
          "template" => name,
          "instances" => 1,
          "resource_pool" => "common",
          "networks" => {
            "name" => "#{name}_network",
            "default" => ["dns", "gateway"],
            "static_ips" => ip_addresses
          }
        }
      end
      
      def base_manifest(name, director_uuid)
        { "name" => name,
          "director_uuid" => director_uuid,
          "release" => {
            "name" => "name",
            "version" => 1 # FIXME detect if any existing releases; use that version
          }
        }
      end
    end
  end
end
