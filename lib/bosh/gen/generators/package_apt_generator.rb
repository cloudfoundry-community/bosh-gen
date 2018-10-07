require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class PackageAptGenerator < Thor::Group
      include Thor::Actions

      argument :name
      argument :dependencies, :type => :array

      def self.source_root
        File.join(File.dirname(__FILE__), "package_apt_generator", "templates")
      end

      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end

      def check_name
        raise Thor::Error.new("'#{name}' is not a valid BOSH id") unless name.bosh_valid_id?
      end

      def warn_missing_dependencies
        dependencies.each do |d|
          raise Thor::Error.new("dependency '#{d}' is not a valid BOSH id") unless d.bosh_valid_id?
          unless File.exist?(File.join("packages", d))
            say_status "warning", "missing dependency '#{d}'", :yellow
          end
        end
      end

      def packaging
        directory 'packages'
        directory 'jobs'
      end

      def show_instructions
        say "Next steps:", :green
        say <<-README.gsub(/^        /, '')
          1. Edit packages/#{name}/packaging to specify list of debian packages to install
          2. Add "#{name}-pkg-install" job into deployment manifest
        README
      end

      private
      def package_dir(path)
        "packages/#{name}/#{path}"
      end

      def src_dir(path)
        "src/#{name}/#{path}"
      end

      def blob_dir(path)
        "blobs/#{name}/#{path}"
      end

      def deb_package_name
        name
      end

    end
  end
end
