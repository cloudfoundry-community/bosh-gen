require 'thor/group'

module Bosh::Gen
  module Generators
    class NewReleaseGenerator < Thor::Group
      include Thor::Actions

      argument :name
      
      def self.source_root
        File.join(File.dirname(__FILE__), "new_release_generator", "templates")
      end
      
      def directories
        %w[jobs packages src blobs].each do |dir|
          directory dir, gen_path(dir)
        end
      end
      
      def blobs_yaml
        blobs = {}
        create_file gen_path("blob_index.yml"), YAML.dump(blobs)
      end
      
      def git_init
        create_file gen_path(".gitignore"), <<-IGNORE.gsub(/^\s{8}/, '')
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
      
      private
      def gen_path(path)
        File.join(name, path)
      end
    end
  end
end
