require "spec_helper"
require "bosh/gen/generators/deployment_manifest_generator"

# in a tmp folder:
# * run generator
# * deployment manifest created

# generates dpeloyment manifest for a target release
describe Bosh::Gen::Generators::DeploymentManifestGenerator do

  xit "creates deployment manifest with properties" do
    setup_project_release("bosh-sample-release")
    release_folder = File.expand_path("../../fixtures/releases/bosh-sample-release", __FILE__)
    in_home_folder do
      generate_manifest("wordpress", release_folder)
      expect(File.exist?("wordpress.yml")).to eq(true)

      manifest = YAML.load_file("wordpress.yml")
      properties = manifest["properties"]
      properties.wont_be_nil "manifest properties must be set"
      properties["mysql"].wont_be_nil
      properties["mysql"]["password"].must_equal 'mysqlpassword'
    end
  end

  it "checks for numerics in filenames/properties" do
    release_folder = File.expand_path("../../tmp", __FILE__)
    setup_project_release("s3test-boshrelease")
    expect(File.exist?(File.join(@active_project_folder, "jobs/s3test/spec"))).to eq true

    dev = YAML.load_file(File.join(@active_project_folder, "config/dev.yml"))
    expect(dev).not_to be_nil
    expect(dev["dev_name"]).to eq "s3test"

    deployment = YAML.load_file(File.join(@active_project_folder, "templates/deployment.yml"))
    expect(deployment["compilation"]["network"]).to eq("s3test1")
  end
end
