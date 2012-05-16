require "spec_helper"
require "bosh/gen/models"

class ReleaseDetectionSpec < MiniTest::Spec
  it "detects latest dev release version" do
    detector = Bosh::Gen::Models::ReleaseDetection.new(fixture_release_path('some_dev_releases'))
    latest_dev_release_version = detector.latest_dev_release_version
    latest_dev_release_version.must_equal 10
  end
  
  it "creates release properties for deployment manifest" do
    detector = Bosh::Gen::Models::ReleaseDetection.new(fixture_release_path('some_dev_releases'))
    detector.latest_dev_release_properties.must_equal({
      "name" => "myrelease",
      "version" => 10
    })
  end
  
  it "returns list of jobs" do
    detector = Bosh::Gen::Models::ReleaseDetection.new(fixture_release_path('some_dev_releases'))
    detector.latest_dev_release_job_names.must_equal %w[redis]
  end
end
