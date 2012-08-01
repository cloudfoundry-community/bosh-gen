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

  def setup
    setup_universe
    setup_project_release("bosh-sample-release")
    in_project_folder do
      generate_job("mywebapp")
    end
  end

  it "creates normal job files" do
    in_project_folder do
      File.exist?("jobs/mywebapp/monit").must_equal true
      File.exist?("jobs/mywebapp/spec").must_equal true
      File.exist?("jobs/mywebapp/templates/mywebapp_ctl").must_equal true
      File.executable?("jobs/mywebapp/templates/mywebapp_ctl").must_equal true
    end
  end
end
