require 'thor/group'

module Bosh::Gen
  module Generators
    class NewReleaseGenerator < Thor::Group
      include Thor::Actions

      argument :app_path
      
      def self.source_root
        File.join(File.dirname(__FILE__), "new_release_generator", "templates")
      end
      
      def create_root
        self.destination_root = File.expand_path(app_path, destination_root)
        empty_directory '.'
        FileUtils.cd(destination_root) unless options[:pretend]
      end
      
      def directories
        %w[jobs packages src blobs].each do |dir|
          directory dir
        end
      end
      
      def blobs_yaml
        blobs = {}
        create_file "blob_index.yml", YAML.dump(blobs)
      end
      
      def git_init
        create_file ".gitignore", <<-IGNORE.gsub(/^\s{8}/, '')
        config/dev.yml
        config/private.yml
        releases/*.tgz
        dev_releases
        blobs
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
