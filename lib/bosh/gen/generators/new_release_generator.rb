require "yaml"
require "thor/group"
require "cyoi/cli/provider"
require "cyoi/cli/blobstore"
require "bosh/gen/settings"

module Bosh::Gen
  module Generators
    class NewReleaseGenerator < Thor::Group
      include Thor::Actions
      include Bosh::Gen::Settings

      argument :proposed_app_path

      def self.source_root
        File.join(File.dirname(__FILE__), "new_release_generator", "templates")
      end

      def create_root
        self.destination_root = File.expand_path(repository_path, destination_root)
        empty_directory '.'
        FileUtils.cd(destination_root) unless options[:pretend]
      end

      def select_provider
        self.settings_dir = File.expand_path("config")
        provider = Cyoi::Cli::Provider.new([settings_dir])
        provider.execute!
        reload_settings!
      end

      def readme
        template "README.md.tt", "README.md"
      end

      def license
        template "LICENSE.md.tt", "LICENSE.md"
      end

      def rakefile
        copy_file "Rakefile"
      end

      def directories
        %w[jobs packages src blobs manifests].each do |dir|
          directory dir
        end
      end

      def blobs_yaml
        create_file "config/blobs.yml", YAML.dump({})
      end

      def config_dev_yml
        config_dev = { "dev_name" => project_name }
        create_file "config/dev.yml", YAML.dump(config_dev)
      end

      def config_private_yml
        case blobstore_type
        when :local
          config_private = {
            "blobstore" => {
              "provider" => "simple",
              "options" => {
                "user" => "USER",
                "password" => "PASSWORD"
              }
            }
          }
        when :s3
          config_private = {
            "blobstore" => {
              "provider" => "s3",
              "options" => {
                "access_key_id" => settings.provider.credentials.aws_access_key_id,
                "secret_access_key" => settings.provider.credentials.aws_secret_access_key
              }
            }
          }
        # https://github.com/cloudfoundry/bosh/tree/master/blobstore_client#openstack-object-storage
        when :swift
          config_private = {
            "blobstore" => {
              "provider" => "swift",
              "options" => {
                settings.provider.name => settings.provider.credentials.to_hash
              }
            }
          }
        end
        create_file "config/private.yml", YAML.dump(config_private)
      end

      def config_final_yml
        case blobstore_type
        when :local
          say_status "warning", "config/final.yml defaulting to local blobstore /tmp/blobstore", :yellow
          config_final = { "blobstore" => {
              "provider" => "local",
              "options" => { "blobstore_path" => '/tmp/blobstore' }
            }
          }
        when :s3
          config_final = { "blobstore" => {
              "provider" => "s3",
              "options" => {
                "bucket_name" => repository_name
              }
            }
          }
        when :swift
          config_final = { "blobstore" => {
              "provider" => "swift",
              "options" => {
                "container_name" => repository_name,
                "swift_provider" => swift_provider
              }
            }
          }
        end
        config_final["final_name"] = project_name

        create_file "config/final.yml", YAML.dump(config_final)
      end

      def git_init
        create_file ".gitignore", <<-IGNORE.gsub(/^\s{8}/, '')
        config/dev.yml
        config/private.yml
        config/settings.yml
        releases/**/*.tgz
        dev_releases
        blobs/*
        .blobs
        .dev_builds
        .vagrant
        .idea
        .DS_Store
        .final_builds/jobs/**/*.tgz
        .final_builds/packages/**/*.tgz
        *.swp
        *~
        *#
        #*
        tmp
        IGNORE
      end

      def setup_git
        git :init
        git :add => "."
        git :commit => "-m 'Initial scaffold'"
      end

      def show_location
        say ""
        say "Next, change to BOSH release location:"
        say "cd #{repository_path}", :yellow
      end

      def create_blobstore
        say ""
        say "Finally..."
        blobstore = Cyoi::Cli::Blobstore.new([blobstore_name, settings_dir])
        blobstore.execute!
        reload_settings!
        say ""
      end



      private

      # converts the base name into having -boshrelease suffix
      def repository_name
        @repository_name ||= "#{project_name}-boshrelease"
      end

      def blobstore_name
        repository_name
      end

      def repository_path
        File.join(File.dirname(proposed_app_path), repository_name)
      end

      def project_name
        @project_name ||= File.basename(proposed_app_path).gsub(/-(?:boshrelease|release)$/, '')
      end

      def warden_net
        @warden_net ||= "10.244.#{rand(255) + 1}"
      end

      def job_name
        project_name_underscored
      end

      def project_name_hyphenated
        project_name.gsub(/[^A-Za-z0-9]+/, '-')
      end

      def project_name_underscored
        project_name.gsub(/[^A-Za-z0-9]+/, '_')
      end

      def blobstore_type
        return :s3 if s3?
        return :swift if swift?
        return :local
      end

      def s3?
        settings.provider.name == "aws"
      end

      def swift?
        settings.provider.name == "openstack"
      end

      # https://github.com/cloudfoundry/bosh/tree/master/blobstore_client#openstack-swift-provider
      # TODO: supported: hp, openstack and rackspace; How to detect this from fog?
      def swift_provider
        "openstack"
      end

      # Run a command in git.
      #
      # ==== Examples
      #
      #   git :init
      #   git :add => "this.file that.rb"
      #   git :add => "onefile.rb", :rm => "badfile.cxx"
      #
      def git(commands={})
        if commands.is_a?(Symbol)
          run "git #{commands}"
        else
          commands.each do |cmd, options|
            run "git #{cmd} #{options}"
          end
        end
      end

      def readwrite_aws_access_key
        s3_credentials "readwrite_access_key", "READWRITE_AWS_ACCESS_KEY"
      end

      def readwrite_aws_secret_access_key
        s3_credentials "readwrite_secret_access_key", "READWRITE_AWS_SECRET_ACCESS_KEY"
      end

      def s3_credentials(key, default)
        @s3_credentials ||= begin
          creds = File.expand_path("~/.bosh_s3_credentials")
          if File.exist?(creds)
            YAML.load_file(creds)
          else
            {}
          end
        end
        @s3_credentials[key] || default
      end

      def year
        Date.today.year
      end

      def author
        `git config --get user.name`.strip
      end
    end
  end
end
