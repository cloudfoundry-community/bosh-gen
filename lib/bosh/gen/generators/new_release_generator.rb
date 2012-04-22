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
          directory dir, File.join(name, dir)
        end
      end
      
      def blobs_yaml
        blobs = {}
        create_file File.join(name, "blob_index.yml"), YAML.dump(blobs)
      end
    end
  end
end
