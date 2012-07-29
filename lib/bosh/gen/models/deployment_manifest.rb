require "yaml"

module Bosh::Gen::Models
  class DeploymentManifest
    attr_reader :manifest
    
    def initialize(name, director_uuid, release_properties, cloud_properties)
      @manifest = {}
      @cloud_properties = cloud_properties
      @security_groups = ["default"]
      @stemcell_version = "0.6.2"
      @stemcell = { "name" => "bosh-stemcell", "version" => @stemcell_version }
      @persistent_disk = cloud_properties.delete("persistent_disk").to_i
      @static_ips = cloud_properties.delete("static_ips") || []

      # Ignore current release version and set to 'latest'
      # This is much more helpful in early development days
      # of a release
      release_properties["version"] = 'latest'
      
      manifest["name"] = name
      manifest["director_uuid"] = director_uuid
      manifest["release"] = release_properties.dup
      manifest["compilation"] = {
        "workers" => 10,
        "network" => "default",
        "cloud_properties" => cloud_properties.dup
      }
      manifest["update"] = {
        "canaries" => 1,
        "canary_watch_time" => 30000,
        "update_watch_time" => 30000,
        "max_in_flight" => 4,
        "max_errors" => 1
      }
      manifest["networks"] = [
        {
          "name" => "default",
          "type" => "dynamic",
          "cloud_properties" => { "security_groups" => @security_groups.dup }
        },
        {
          "name" => "vip_network",
          "type" => "vip",
          "cloud_properties" => { "security_groups" => @security_groups.dup }
        }
      ]
      manifest["resource_pools"] = [
        {
          "name" => "common",
          "network" => "default",
          "size" => 0,
          "stemcell" => @stemcell,
          "cloud_properties" => cloud_properties.dup
        }
      ]
      manifest["resource_pools"].first["persistent_disk"] = @persistent_disk if @persistent_disk > 0
      manifest["jobs"] = []
      manifest["properties"] = {}
    end
    
    # Each item of +jobs+ is a hash. 
    # The minimum hash is:
    # { "name" => "jobname" }
    # This is the equivalent to:
    # { "name" => "jobname", "template" => "jobname", "instances" => 1}
    def jobs=(jobs)
      total_instances = 0
      static_ips = @static_ips.dup
      manifest["jobs"] = []
      jobs.each do |job|
        job_instances = job["instances"] || 1
        manifest_job = {
          "name" => job["name"],
          "template" => job["template"] || job["name"],
          "instances" => job_instances,
          "resource_pool" => "common",
          "networks" => [
            {
              "name" => "default",
              "default" => %w[dns gateway]
            }
          ]
        }
        if static_ips.length > 0
          job_ips, static_ips = static_ips[0..job_instances-1], static_ips[job_instances..-1]
          manifest_job["networks"] << {
            "name" => "vip_network",
            "static_ips" => job_ips
          }
        end
        manifest_job["persistent_disk"] = @persistent_disk if @persistent_disk > 0
        manifest["jobs"] << manifest_job
      end
      manifest["resource_pools"].first["size"] = manifest["jobs"].inject(0) {|total, job| total + job["instances"]}
    end
    
    def to_yaml
      manifest.to_yaml
    end
  end
end