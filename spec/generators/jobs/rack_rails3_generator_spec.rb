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
  end

  # it "creates common job files" do
  #   in_project_folder do
  #     generate_job("mywebapp")
  #     File.exist?("jobs/mywebapp/monit").must_equal(true, "jobs/mywebapp/monit not created")
  #     File.exist?("jobs/mywebapp/spec").must_equal(true, "jobs/mywebapp/spec not created")
  #     job_template_exists "mywebapp", "mywebapp_ctl",     "bin/mywebapp_ctl"
  #     job_template_exists "mywebapp", "ctl_setup.sh.erb",     "bin/ctl_setup.sh"
  #     job_template_exists "mywebapp", "ctl_utils.sh",         "bin/ctl_utils.sh"
  #     job_template_exists "mywebapp", "monit_debugger",       "bin/monit_debugger"
  #   end
  # end

  it "creates job files with rails & nginx templates" do
    in_project_folder do
      generate_job("mywebapp", "--purpose", "nginx_rack", '-d', 'nginx', 'ruby', 'myapp')
      File.exist?("jobs/mywebapp/monit").must_equal(true, "jobs/mywebapp/monit not created")
      File.exist?("jobs/mywebapp/spec").must_equal(true, "jobs/mywebapp/spec not created")

      job_spec("mywebapp")["packages"].must_equal(%w[nginx ruby myapp], "spec dependencies incorrect")

      job_template_exists "mywebapp", "bin/mywebapp_rack_ctl","bin/mywebapp_rack_ctl"
      job_template_exists "mywebapp", "ctl_setup.sh.erb",     "bin/ctl_setup.sh"
      job_template_exists "mywebapp", "ctl_utils.sh",         "bin/ctl_utils.sh"
      job_template_exists "mywebapp", "monit_debugger",       "bin/monit_debugger"
      job_template_exists "mywebapp", "ctl_db_utils.sh.erb",  "bin/ctl_db_utils.sh"
      job_template_exists "mywebapp", "ctl_redis_utils.sh.erb", "bin/ctl_redis_utils.sh"
      job_template_exists "mywebapp", "rails_ctl_setup.sh.erb", "bin/rails_ctl_setup.sh"
      job_template_exists "mywebapp", "ctl_start.sh.erb",     "bin/ctl_start.sh"
      job_template_exists "mywebapp", "ctl_nginx.sh.erb",     "bin/ctl_nginx.sh"
      job_template_exists "mywebapp", "nginx_ctl",            "bin/nginx_ctl"
      job_template_exists "mywebapp", "nginx.conf.erb",       "config/nginx.conf"
      job_template_exists "mywebapp", "nginx_proxy.conf",     "config/nginx_proxy.conf"
      job_template_exists "mywebapp", "mime.types",           "config/mime.types"
      job_template_exists "mywebapp", "database.yml.erb",     "config/database.yml"
      job_template_exists "mywebapp", "redis.yml.erb",        "config/redis.yml"
      job_template_exists "mywebapp", "blacklist.txt",        "config/blacklist.txt"
    end
  end
end
