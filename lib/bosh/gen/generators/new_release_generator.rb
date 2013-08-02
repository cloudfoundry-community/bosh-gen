require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class NewReleaseGenerator < Thor::Group
      include Thor::Actions

      argument :app_path
      argument :flags, :type => :hash
      
      def self.source_root
        File.join(File.dirname(__FILE__), "new_release_generator", "templates")
      end
      
      def create_root
        self.destination_root = File.expand_path(app_path, destination_root)
        empty_directory '.'
        FileUtils.cd(destination_root) unless options[:pretend]
      end
      
      def readme
        template "README.md.tt", "README.md"
      end
      
      def rakefile
        copy_file "Rakefile"
      end
      
      def directories
        %w[jobs packages src blobs].each do |dir|
          directory dir
        end
      end
      
      def blobs_yaml
        create_file "config/blobs.yml", YAML.dump({})
      end
      
      # TODO - support other blobstores
      def local_blobstore
        config_dev = { "dev_name" => project_name }
        create_file "config/dev.yml", YAML.dump(config_dev)

        case blobstore_type
        when :local
          config_private = { 
            "blobstore" => {
              "simple" => {
                "user" => "USER",
                "password" => "PASSWORD"
              }
            }
          }
        when :s3
          config_private = { 
            "blobstore" => {
              "s3" => {
                "access_key_id" => readwrite_aws_access_key,
                "secret_access_key" => readwrite_aws_secret_access_key
              }
            }
          }
        when :atmos
          config_private = { 
            "blobstore" => {
              "atmos" => {
                "secret" => "SECRET"
              }
            }
          }
        when :swift
          config_private = {
            "blobstore" => {
              "swift" => {
                "rackspace" => {
                  "rackspace_username" => "USERNAME",
                  "rackspace_api_key" => "API_KEY"
                },
                "hp" => {
                  "hp_account_id" => "ACCESS_KEY_ID",
                  "hp_secret_key" => "SECRET_KEY",
                  "hp_tenant_id" => "TENANT_ID"
                },
              }
            }
          }
        end
        create_file "config/private.yml", YAML.dump(config_private)

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
                "bucket_name" => "BOSH",
                "access_key_id" => readonly_aws_access_key,
                "secret_access_key" => readonly_aws_secret_access_key,
                "encryption_key" => "PERSONAL_RANDOM_KEY",
              }
            }
          }
        when :atmos
          config_final = { "blobstore" => {
              "provider" => "atmos",
              "options" => {
                "tag" => "BOSH",
                "url" => "https://blob.cfblob.com",
                "uid" => "ATMOS_UID"
              }
            }
          }
        when :swift
          config_final = { "blobstore" => {
              "provider" => "swift",
              "options" => {
                "container_name" => "BOSH",
                "swift_provider" => "SWIFT_PROVIDER"
              }
            }
          }
        end
        
        create_file "config/final.yml", YAML.dump(config_final)
      end
      
      def git_init
        create_file ".gitignore", <<-IGNORE.gsub(/^\s{8}/, '')
        config/dev.yml
        config/private.yml
        releases/*.tgz
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
        IGNORE
      end
      
      def setup_git
        git :init
        git :add => "."
        git :commit => "-m 'Initial scaffold'"
      end
      
      private
      
      def project_name
        @project_name ||= repository_name.gsub(/-(?:boshrelease|release)$/, '')
      end

      def repository_name
        @repository_name ||= File.basename(app_path)
      end

      def blobstore_type
        return :s3 if s3?
        return :atmos if atmos?
        return :swift if swift?
        return :local
      end
      
      def s3?
        flags[:aws]
      end
      
      def atmos?
        flags[:atmos]
      end

      def swift?
        flags[:swift]
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

      def readonly_aws_access_key
        s3_credentials "readonly_access_key", "READONLY_AWS_ACCESS_KEY"
      end

      def readonly_aws_secret_access_key
        s3_credentials "readonly_secret_access_key", "READONLY_AWS_SECRET_ACCESS_KEY"
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
    end
  end
end
