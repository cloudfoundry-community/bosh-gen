require "json"

module Bosh::Gen::Models
  class BoshStatus
    
    def to_json
      raise Bosh::Gen::Models::BoshCliOutputChanged.new
      {}.to_json
    end
  end
end