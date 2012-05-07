require "yaml"

module Bosh::Gen::Models
  class DeploymentManifest
    def initialize(name, director_uuid, cloud_properties)
      @name = name
      @director_uuid = director_uuid
      @cloud_properties = cloud_properties
    end
    
    def jobs=(jobs)
      
    end
    
    def to_yaml
      {}.to_yaml
    end
  end
end