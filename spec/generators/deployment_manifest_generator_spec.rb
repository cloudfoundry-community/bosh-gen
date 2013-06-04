require "spec_helper"
require "generators/generator_spec_helper"

# in a tmp folder:
# * run generator
# * deployment manifest created

# generates dpeloyment manifest for a target release
class DeploymentManifestGeneratorSpec < MiniTest::Spec
  include GeneratorSpecHelper

  def self.pending(name, &block); end

  def setup
    setup_universe
    setup_project_release("bosh-sample-release")
  end

  pending "creates deployment manifest with properties" do
    release_folder = File.expand_path("../../fixtures/releases/bosh-sample-release", __FILE__)
    in_home_folder do
      generate_manifest("wordpress", release_folder)
      
      File.exist?("wordpress.yml").must_equal(true, "manifest wordpress.yml not created")
      
      manifest = YAML.load_file("wordpress.yml")
      properties = manifest["properties"]
      properties.wont_be_nil "manifest properties must be set"
      properties["mysql"].wont_be_nil
      properties["mysql"]["password"].must_equal 'mysqlpassword'
    end
  end
end