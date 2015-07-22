require "spec_helper"
require "bosh/gen/generators/new_release_generator"

describe Bosh::Gen::Generators::NewReleaseGenerator do
  include Bosh::Gen::Settings

  def cyoi_provider
    provider = instance_double("Cyoi::Cli::Provider")
    expect(provider).to receive(:execute!)
    expect(Cyoi::Cli::Provider).to receive(:new).with([settings_dir]).and_return(provider)
    provider
  end

  def cyoi_blobstore(blobstore_name)
    blobstore = instance_double("Cyoi::Cli::Blobstore")
    expect(blobstore).to receive(:execute!)
    expect(Cyoi::Cli::Blobstore).to receive(:new).with([blobstore_name, settings_dir]).and_return(blobstore)
    blobstore
  end

  before do
    in_home_folder do
      self.settings_dir = "redis-boshrelease/config"
      cyoi_provider
      cyoi_blobstore "redis-boshrelease"
    end
  end

  it "generates with s3 blobstore" do
    in_home_folder do

      setting "provider.name", "aws"
      setting "provider.region", "us-west-2"
      setting "provider.credentials.aws_access_key_id", "ACCESS"
      setting "provider.credentials.aws_secret_access_key", "SECRET"

      generate_new_release 'redis'
      expect(File.directory?("jobs")).to eq(true)

      config = YAML.load_file("config/final.yml")
      expect(config).to_not be_nil
      expect(config["final_name"]).to eq("redis")
      expect(config["blobstore"]).to_not be_nil
      expect(config["blobstore"]["options"]).to_not be_nil
      expect(config["blobstore"]["provider"]).to eq("s3")
      expect(config["blobstore"]["options"].keys).to eq(["bucket_name"])
      expect(config["blobstore"]["options"]["bucket_name"]).to eq("redis-boshrelease")

      config = YAML.load_file("config/private.yml")
      expect(config).to_not be_nil
      expect(config["blobstore"]).to_not be_nil
      expect(config["blobstore"]["s3"]).to_not be_nil
      expect(config["blobstore"]["s3"]["access_key_id"]).to eq("ACCESS")
      expect(config["blobstore"]["s3"]["secret_access_key"]).to eq("SECRET")
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
      expect(File.directory?("jobs")).to eq(true)

      config = YAML.load_file("config/final.yml")
      expect(config).to_not be_nil
      expect(config["final_name"]).to eq("redis")
      expect(config["blobstore"]).to_not be_nil
      expect(config["blobstore"]["options"]).to_not be_nil
      expect(config["blobstore"]["provider"]).to eq("swift")
      expect(config["blobstore"]["options"].keys).to eq(["container_name", "swift_provider"])
      expect(config["blobstore"]["options"]["container_name"]).to eq("redis-boshrelease")

      config = YAML.load_file("config/private.yml")
      expect(config).to_not be_nil
      expect(config["blobstore"]).to_not be_nil
      expect(config["blobstore"]["swift"]["openstack"]).to_not be_nil
      expect(config["blobstore"]["swift"]["openstack"]["openstack_auth_url"]).to eq("http://10.0.0.2:5000/v2.0/tokens")
      expect(config["blobstore"]["swift"]["openstack"].keys).to eq(["openstack_auth_url", "openstack_username", "openstack_api_key", "openstack_tenant", "openstack_region"])
    end
  end

  # generate_new_release 'redis'
  # generate_new_release 'redis-boshrelease'
end
