require "spec_helper"
require "bosh/gen/models"

class BoshConfigSpec < MiniTest::Spec
  it "knows UUID of current target bosh" do
    fake_config = File.expand_path( \
      "../../fixtures/bosh_config/multiple_boshes.yml", __FILE__)
    config = Bosh::Gen::Models::BoshConfig.new(fake_config)
    config.target_uuid.must_equal "f734ed1f-6892-4d96-9123-018c830a8543"
  end
end