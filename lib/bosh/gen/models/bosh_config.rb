require "yaml"
module Bosh::Gen::Models
  # Read-only interface to local ~/.bosh_config
  # file
  class BoshConfig
    def initialize(config_file="~/.bosh_config")
      @config_file = File.expand_path(config_file)
      @config = YAML.load_file(@config_file)
    end
    
    def target_uuid
      @config["target_uuid"]
    end
  end
end
