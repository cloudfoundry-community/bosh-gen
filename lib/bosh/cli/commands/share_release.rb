require 'bosh/gen/utils/file_with_progress_bar'

module Bosh::Cli::Command
  class ShareRelease < Base
    usage "share release"
    desc  "upload release tarball to blobstore"
    def share_release(tarball_path)
      # need to be in release dir to get blobstore credentials
      check_if_release_dir

      unless File.exist?(tarball_path)
        err("Release tarball file doesn't exist")
      end

      tarball = Bosh::Cli::ReleaseTarball.new(tarball_path)
      say("\nVerifying release...")
      tarball.validate(:allow_sparse => true)
      nl

      unless tarball.valid?
        err('Release is invalid, please fix, verify and upload again')
      end

      upload_name = "boshrelease-#{tarball.release_name}-#{tarball.version}.tgz"

      f = ::FileWithProgressBar.open(tarball_path, 'r')
      f.out = Bosh::Cli::Config.output

      # p release
      # p release.blobstore
      raw_blobstore_client = unwrap_blobstore_client(blobstore)
      bucket_name = raw_blobstore_client.instance_variable_get("@bucket_name")

      fog = fog_storage(raw_blobstore_client)
      dir = fog.directories.get(bucket_name)

      say("\nUploading release...")
      if file = dir.files.new(key: upload_name, body: f)
        file.public = true
        file.save
        nl
        say(file.public_url)
      else
        err('Failed to upload file to blobstore')
      end
    end

    private
    def unwrap_blobstore_client(blobstore)
      if blobstore.is_a?(Bosh::Blobstore::RetryableBlobstoreClient)
        unwrap_blobstore_client(blobstore.instance_variable_get("@client"))
      elsif blobstore.is_a?(Bosh::Blobstore::Sha1VerifiableBlobstoreClient)
        unwrap_blobstore_client(blobstore.instance_variable_get("@client"))
      else
        blobstore
      end
    end

    def fog_storage(blobstore)
      blobstore_options = blobstore.instance_variable_get("@options")
      if blobstore.is_a?(Bosh::Blobstore::S3BlobstoreClient)
        require "fog/aws"
        return Fog::Storage.new(
          provider: 'AWS',
          aws_access_key_id: blobstore_options[:access_key_id],
          aws_secret_access_key: blobstore_options[:secret_access_key],
        )
      # elsif blobstore.is_a?(Bosh::Blobstore::SwiftBlobstoreClient)
      #   require "fog/openstack"
      #   return Fog::Storage.new(
      #     provider: 'OpenStack',
      #     aws_access_key_id: blobstore_options[:access_key_id],
      #     aws_secret_access_key: blobstore_options[:secret_access_key],
      #   )
      else
        err('Not yet implemented for #{blobstore.class} blobstore')
      end
    end
  end
end
