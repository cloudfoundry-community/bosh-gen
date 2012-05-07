require "minitest/spec"
require "minitest-colorize"
require "bosh/gen/models"

class DeploymentManifestSpec < MiniTest::Spec
  it "creates manifest document with 1 job with defaults" do
    manifest = Bosh::Gen::Models::DeploymentManifest.new("myproj", "UUID", {"instance_type" => "m1.small"})
    manifest.jobs = [
      { "name" => "job-with-ips",  "static_ips" => ['1.2.3.4']},
      { "name" => "misc"}
    ]
    manifest.to_yaml.must_equal fixture_manifest("defaults")
  end
  
  def fixture_manifest(name)
    File.read(File.expand_path("../../fixtures/deployment_manifests/#{name}.yml", __FILE__))
  end
end
