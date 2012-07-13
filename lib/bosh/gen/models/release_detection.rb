require "yaml"

module Bosh::Gen::Models
  class ReleaseDetection
    attr_reader :release_path
    attr_reader :latest_dev_release
    
    def initialize(release_path)
      @release_path = release_path

      @dev_config = YAML.load_file(File.join(release_path, "config", "dev.yml"))
      @latest_dev_release_filename = File.expand_path(@dev_config["latest_release_filename"], release_path) # absolute or relative
      @latest_dev_release = YAML.load_file(@latest_dev_release_filename)
    end
    
    def latest_dev_release_name
      @latest_dev_release["name"]
    end

    def latest_dev_release_version
      @latest_dev_release["version"]
    end
    
    def latest_dev_release_job_names
      @latest_dev_release["jobs"].map {|job| job["name"]}
    end
    
    def latest_dev_release_properties
      {
        "name" => latest_dev_release_name,
        "version" => latest_dev_release_version
      }
    end
  end
end