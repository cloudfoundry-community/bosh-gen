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
        config_dev = { "dev_name" => name }
        create_file "config/dev.yml", YAML.dump(config_dev)

        config_private = { "blobstore_secret" => 'BLOBSTORE_SECRET' }
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
          config_private = { "blobstore_secret" => 'BLOBSTORE_SECRET' }
          config_final = { "blobstore" => {
              "provider" => "s3",
              "options" => {
                "bucket_name" => "BOSH",
                "access_key_id" => "AWS_ACCESS_KEY",
                "secret_access_key" => "AWS_SECRET_ACCESS_KEY",
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
      
      def name
        File.basename(self.destination_root)
      end
      
      def blobstore_type
        return :s3 if s3?
        return :atmos if atmos?
        return :local
      end
      
      def s3?
        flags[:aws]
      end
      
      def atmos?
        flags[:atmos]
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
    end
  end
end
