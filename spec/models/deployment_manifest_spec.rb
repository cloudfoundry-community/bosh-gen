require "spec_helper"
require "bosh/gen/models"

describe Bosh::Gen::Models::DeploymentManifest do
  it "creates manifest document with 2 jobs, no disk" do
    manifest = Bosh::Gen::Models::DeploymentManifest.new("myproj", "UUID",
      {"name" => "myrelease", "version" => 2},
      {"instance_type" => "m3.medium", "static_ips" => ['1.2.3.4', '6.7.8.9']}, {})
    manifest.jobs = [
      { "name" => "job-with-ips"},
      { "name" => "misc"}
    ]
    expect(manifest.to_yaml).to eq fixture_manifest("2_jobs_2_ips_no_disk")
  end

  it "creates manifest document with 2 jobs, with disk" do
    manifest = Bosh::Gen::Models::DeploymentManifest.new("myproj", "UUID",
      {"name" => "myrelease", "version" => 2},
      {"instance_type" => "m3.medium", "persistent_disk" => "8196",  "static_ips" => ['1.2.3.4']}, {})
    manifest.jobs = [
      { "name" => "job-with-ips"},
      { "name" => "misc"}
    ]
    expect(manifest.to_yaml).to eq fixture_manifest("2_jobs_1_ip_8196_disk")
  end
  it "creates manifest document with 2 jobs, with disk, numeric in manifest name" do
    manifest = Bosh::Gen::Models::DeploymentManifest.new("s3test", "UUID",
      {"name" => "myrelease", "version" => 2},
      {"instance_type" => "m3.medium", "persistent_disk" => "8196",  "static_ips" => ['4.3.2.1']}, {})
    manifest.jobs = [
      { "name" => "job-with-ips"},
      { "name" => "misc"}
    ]
    expect(manifest.to_yaml).to eq fixture_manifest("2_jobs_1_ip_8196_disk_with_numeric")
  end

  def fixture_manifest(name)
    File.read(File.expand_path("../../fixtures/deployment_manifests/#{name}.yml", __FILE__))
  end
end
