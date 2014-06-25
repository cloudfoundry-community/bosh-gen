require "spec_helper"
require "generators/generator_spec_helper"

class NewReleaseGeneratorSpec < MiniTest::Spec
  include GeneratorSpecHelper
  include Bosh::Gen::Settings

  def self.pending(name, &block); end

  def setup
    setup_universe
  end

  # should load creds from a file OR prompt for creds
  # use cyoi?
  # then create the bucket & policy

  it "generates with s3 blobstore" do
    in_home_folder do
      setting "provider.name", "aws"
      setting "provider.region", "us-west-2"
      setting "provider.credentials.aws_access_key_id", "ACCESS"
      setting "provider.credentials.aws_secret_access_key", "SECRET"

      generate_new_release 'redis'
      File.directory?("jobs").must_equal(true, "jobs folder not created")

      config = YAML.load_file("config/final.yml")
      config.wont_be_nil "final.yml is nil"
      config["blobstore"].wont_be_nil "final.yml doesn't have blobstore"
      config["blobstore"]["options"].wont_be_nil "final.yml doesn't have blobstore.options"
      config["blobstore"]["provider"].must_equal("s3")
      config["blobstore"]["options"].keys.must_equal(["bucket_name"])
      config["blobstore"]["options"]["bucket_name"].must_equal("redis-boshrelease")

      config = YAML.load_file("config/private.yml")
      config.wont_be_nil "private.yml is nil"
      config["blobstore"].wont_be_nil "private.yml doesn't have blobstore"
      config["blobstore"]["s3"].wont_be_nil "final.yml doesn't have blobstore.s3"
      config["blobstore"]["s3"]["access_key_id"].must_equal("ACCESS")
      config["blobstore"]["s3"]["secret_access_key"].must_equal("SECRET")
    end
  end

  it "generates with swift blobstore" do
    in_home_folder do
      setting "provider.name", "openstack"
      setting "provider.credentials.openstack_auth_url", "http://10.0.0.2:5000/v2.0/tokens"
      setting "provider.credentials.openstack_username", "USER"
      setting "provider.credentials.openstack_api_key", "PASSWORD"
      setting "provider.credentials.openstack_tenant", "TENANT"
      setting "provider.credentials.openstack_region", "REGION"

      # TODO: get rid of this prompt from Cyoi::Provider
      setting "provider.options.boot_from_volume", false

      generate_new_release 'redis'
      File.directory?("jobs").must_equal(true, "jobs folder not created")

      config = YAML.load_file("config/final.yml")
      config.wont_be_nil "final.yml is nil"
      config["blobstore"].wont_be_nil "final.yml doesn't have blobstore"
      config["blobstore"]["options"].wont_be_nil "final.yml doesn't have blobstore.options"
      config["blobstore"]["provider"].must_equal("swift")
      config["blobstore"]["options"].keys.must_equal(["container_name", "swift_provider"])
      config["blobstore"]["options"]["container_name"].must_equal("redis-boshrelease")

      config = YAML.load_file("config/private.yml")
      config.wont_be_nil "private.yml is nil"
      config["blobstore"].wont_be_nil "private.yml doesn't have blobstore"
      config["blobstore"]["swift"]["openstack"].wont_be_nil "final.yml doesn't have blobstore.s3"
      config["blobstore"]["swift"]["openstack"]["openstack_auth_url"].must_equal("http://10.0.0.2:5000/v2.0/tokens")
      config["blobstore"]["swift"]["openstack"].keys.must_equal(["openstack_auth_url", "openstack_username", "openstack_api_key", "openstack_tenant", "openstack_region"])
    end
  end

  # generate_new_release 'redis'
  # generate_new_release 'redis-boshrelease'
end
