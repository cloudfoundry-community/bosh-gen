require "spec_helper"
require "bosh/gen/generators/job_generator"

# in a tmp folder:
# * run generator
# * specific files created
# * run 'bosh create release'
# * it shouldn't fail

# generates job for a webapp application package
describe Bosh::Gen::Generators::JobGenerator do
  before do
    setup_project_release("bosh-sample-release")
  end

  it "creates common job files" do
    in_project_folder do
      generate_job("mywebapp")
      expect(File.exist?("jobs/mywebapp/monit")).to eq(true)
      expect(File.exist?("jobs/mywebapp/spec")).to eq(true)
      job_template_exists "mywebapp", "bin/ctl",                "bin/ctl"
      job_template_exists "mywebapp", "bin/monit_debugger",     "bin/monit_debugger"
      job_template_exists "mywebapp", "data/properties.sh.erb", "data/properties.sh"
      job_template_exists "mywebapp", "helpers/ctl_setup.sh",   "helpers/ctl_setup.sh"
      job_template_exists "mywebapp", "helpers/ctl_utils.sh",   "helpers/ctl_utils.sh"
    end
  end

end
