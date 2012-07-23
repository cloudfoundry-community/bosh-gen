require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class ExtractPackageGenerator < Thor::Group
      include Thor::Actions

      argument :source_release_path
      argument :source_package_name
      
      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end
      
      def using_source_release_for_templates
        source_paths << File.join(source_release_path)
      end

      # Extract target package and all its dependencies
      def detect_dependent_packages
        spec = YAML.load_file(source_package_dir("spec"))
        @packages = [target_package_name]
        @packages << spec["packages"] if spec["packages"]
      end
      
      def copy_dependent_packages
        @packages.each {|package| directory "packages/#{package}"}
      end

      def copy_dependent_sources
        @blobs = false
        @packages.each do |package|
          directory "src/#{package}" if File.exist?(File.join(source_release_path, "src", package))
          if File.exist?(File.join(source_release_path, "blobs", package))
            directory "blobs/#{package}"
            @blobs = true
          end
        end
      end
      
      def readme
        if @blobs
          say_status "readme", "Upload blobs with 'bosh upload blobs'"
        end
      end
      
      private
      def target_package_name
        source_package_name
      end
      
      def package_dir(path="")
        File.join("packages", source_package_name, path)
      end
      
      def source_package_dir(path="")
        File.join(source_release_path, "packages", source_package_name, path)
      end
      
    end
  end
end
