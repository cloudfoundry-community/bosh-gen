require "yaml"

module Bosh::Gen::Models
  class DeploymentManifest
    attr_reader :manifest
    
    def initialize(name, director_uuid, release_properties, cloud_properties)
      @manifest = {}
      @cloud_properties = cloud_properties
      @security_groups = ["default"]
      @stemcell_version = "0.5.1"
      @stemcell = { "name" => "bosh-stemcell", "version" => @stemcell_version }
      @persistent_disk = cloud_properties.delete("persistent_disk").to_i
      
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
    #
    # A +jobs+ item can also include a +"static_ips" item, which is an array of strings:
    # { "name" => "jobname", "static_ips" => ['1.2.3.4', '9.8.7.6']}
    def jobs=(jobs)
      total_instances = 0
      manifest["jobs"] = []
      jobs.each do |job|
        manifest_job = {
          "name" => job["name"],
          "template" => job["template"] || job["name"],
          "instances" => job["instances"] || 1,
          "resource_pool" => "common",
          "networks" => [
            {
              "name" => "default",
              "default" => %w[dns gateway]
            }
          ]
        }
        if job["static_ips"]
          manifest_job["networks"] << {
            "name" => "vip_network",
            "static_ips" => job["static_ips"]
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