require "spec_helper"
require "generators/generator_spec_helper"

# in a tmp folder:
# * run generator
# * specific files created
# * run 'bosh create release'
# * it shouldn't fail

# generates job for a webapp application package
class WebappGeneratorSpec < MiniTest::Spec
  include GeneratorSpecHelper

  def self.pending(name, &block); end

  def setup
    setup_universe
    setup_project_release("bosh-sample-release")
  end

  it "creates common job files" do
    in_project_folder do
      generate_job("mywebapp")
      File.exist?("jobs/mywebapp/monit").must_equal(true, "jobs/mywebapp/monit not created")
      File.exist?("jobs/mywebapp/spec").must_equal(true, "jobs/mywebapp/spec not created")
      job_template_exists "mywebapp", "bin/mywebapp_ctl",       "bin/mywebapp_ctl"
      job_template_exists "mywebapp", "bin/monit_debugger",     "bin/monit_debugger"
      job_template_exists "mywebapp", "data/properties.sh.erb", "data/properties.sh"
      job_template_exists "mywebapp", "helpers/ctl_setup.sh",   "helpers/ctl_setup.sh"
      job_template_exists "mywebapp", "helpers/ctl_utils.sh",   "helpers/ctl_utils.sh"

      example = File.join("examples", "mywebapp.yml")
      File.exist?(example).must_equal(true, "#{example} not created")
    end
  end

  pending "creates job files with rails & nginx templates" do
    in_project_folder do
      generate_job("mywebapp", "--purpose", "nginx_rack", '-d', 'nginx', 'ruby', 'myapp')
      File.exist?("jobs/mywebapp/monit").must_equal(true, "jobs/mywebapp/monit not created")
      File.exist?("jobs/mywebapp/spec").must_equal(true, "jobs/mywebapp/spec not created")

      job_spec("mywebapp")["packages"].must_equal(%w[nginx ruby myapp], "spec dependencies incorrect")

      job_template_exists "mywebapp", "bin/mywebapp_ctl",       "bin/mywebapp_ctl"
      job_template_exists "mywebapp", "bin/monit_debugger",     "bin/monit_debugger"
      job_template_exists "mywebapp", "data/properties.sh.erb",     "data/properties.sh"
      job_template_exists "mywebapp", "helpers/ctl_setup.sh.erb",   "helpers/ctl_setup.sh"
      job_template_exists "mywebapp", "helpers/ctl_utils.sh",       "helpers/ctl_utils.sh"

      job_template_exists "mywebapp", "bin/ctl_db_utils.sh.erb",  "bin/ctl_db_utils.sh"
      job_template_exists "mywebapp", "bin/ctl_redis_utils.sh.erb", "bin/ctl_redis_utils.sh"
      job_template_exists "mywebapp", "bin/rails_ctl_setup.sh.erb", "bin/rails_ctl_setup.sh"
      job_template_exists "mywebapp", "bin/ctl_start.sh.erb",     "bin/ctl_start.sh"
      job_template_exists "mywebapp", "bin/ctl_nginx.sh.erb",     "bin/ctl_nginx.sh"
      job_template_exists "mywebapp", "bin/nginx_ctl",            "bin/nginx_ctl"
      job_template_exists "mywebapp", "config/nginx.conf.erb",    "config/nginx.conf"
      job_template_exists "mywebapp", "config/nginx_proxy.conf",  "config/nginx_proxy.conf"
      job_template_exists "mywebapp", "config/mime.types",        "config/mime.types"
      job_template_exists "mywebapp", "config/database.yml.erb",  "config/database.yml"
      job_template_exists "mywebapp", "config/redis.yml.erb",     "config/redis.yml"

      example = File.join("examples", "mywebapp_nginx_rack", "nginx_puma.yml")
      example = File.join("examples", "mywebapp_nginx_rack", "nginx_rackup.yml")
      File.exist?(example).must_equal(true, "#{example} not created")
    end
  end
end
