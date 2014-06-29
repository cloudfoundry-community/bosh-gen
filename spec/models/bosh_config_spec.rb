require "spec_helper"
require "bosh/gen/models"

describe Bosh::Gen::Models::BoshConfig do
  it "knows UUID of current target bosh" do
    fake_config = File.expand_path( \
      "../../fixtures/bosh_config/multiple_boshes.yml", __FILE__)
    config = Bosh::Gen::Models::BoshConfig.new(fake_config)
    expect(config.target_uuid).to eq "f734ed1f-6892-4d96-9123-018c830a8543"
  end
end
