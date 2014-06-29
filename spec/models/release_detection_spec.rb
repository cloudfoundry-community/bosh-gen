require "spec_helper"
require "bosh/gen/models"

describe Bosh::Gen::Models::ReleaseDetection do
  it "detects latest dev release version" do
    detector = Bosh::Gen::Models::ReleaseDetection.new(fixture_release_path('some_dev_releases'))
    latest_dev_release_version = detector.latest_dev_release_version
    expect(latest_dev_release_version).to eq 10
  end

  it "creates release properties for deployment manifest" do
    detector = Bosh::Gen::Models::ReleaseDetection.new(fixture_release_path('some_dev_releases'))
    expect(detector.latest_dev_release_properties).to eq({
      "name" => "myrelease",
      "version" => 10
    })
  end

  it "returns list of jobs" do
    detector = Bosh::Gen::Models::ReleaseDetection.new(fixture_release_path('some_dev_releases'))
    expect(detector.latest_dev_release_job_names).to eq %w[redis]
  end
end
