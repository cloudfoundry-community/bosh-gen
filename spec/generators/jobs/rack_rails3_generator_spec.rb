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

  it "creates common job files" do
    in_project_folder do
      job_file_exists "mywebapp", "monit"
      job_file_exists "mywebapp", "spec"
      job_file_exists "mywebapp", "templates", "mywebapp_ctl", :executable => true
    end
  end
end
