require "spec_helper"
require "generators/generator_spec_helper"

# in a tmp folder:
# * run generator
# * specific files created
# * run 'bosh create release'
# * it shouldn't fail

# generates job for rails/rack application package
class RackRailsGeneratorSpec < MiniTest::Spec
  include GeneratorSpecHelper

  def self.before_suite
    setup_universe
    setup_fixture_release("bosh-sample-release")
  end

  it "creates job spec" do
    File.exist?("jobs/mysql/spec")
  end
end