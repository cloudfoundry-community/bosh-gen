require "spec_helper"
require "generators/generator_spec_helper"

class NewReleaseGeneratorSpec < MiniTest::Spec
  include GeneratorSpecHelper

  def self.pending(name, &block); end

  def setup
    setup_universe
  end

  it "generates with s3 blobstore" do
    in_home_folder do
      generate_new_release 'redis', '--s3'
      File.directory?("jobs").must_equal(true, "jobs folder not created")

      final = YAML.load_file("config/final.yml")
      final.wont_be_nil "final.yml is nil"
      final["blobstore"].wont_be_nil "final.yml doesn't have blobstore"
      final["blobstore"]["options"].wont_be_nil "final.yml doesn't have blobstore.options"
      final["blobstore"]["provider"].must_equal("s3")
      final["blobstore"]["options"].keys.must_equal(["bucket_name"])
      final["blobstore"]["options"]["bucket_name"].must_equal("redis-boshrelease")
    end
  end

  it "generates with swift blobstore" do
    in_home_folder do
      generate_new_release 'redis', '--swift'
      File.directory?("jobs").must_equal(true, "jobs folder not created")

      final = YAML.load_file("config/final.yml")
      final.wont_be_nil "final.yml is nil"
      final["blobstore"].wont_be_nil "final.yml doesn't have blobstore"
      final["blobstore"]["options"].wont_be_nil "final.yml doesn't have blobstore.options"
      final["blobstore"]["provider"].must_equal("swift")
      final["blobstore"]["options"].keys.must_equal(["container_name", "swift_provider"])
      final["blobstore"]["options"]["container_name"].must_equal("redis-boshrelease")
    end
  end

  # generate_new_release 'redis'
  # generate_new_release 'redis-boshrelease'
  # generate_new_release 'redis', '--s3'
  # generate_new_release 'redis', '--swift'

end
