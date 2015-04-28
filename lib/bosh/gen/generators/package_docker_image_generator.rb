require 'thor/group'

# for the #sh helper
require 'rake'
require 'rake/file_utils'

module Bosh::Gen
  module Generators
    class PackageDockerImageGenerator < Thor::Group
      include Thor::Actions

      class RakeHelper
        extend FileUtils
      end

      argument :name
      argument :docker_image

      def self.source_root
        File.join(File.dirname(__FILE__), "package_docker_image_generator", "templates")
      end

      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end

      def check_name
        raise Thor::Error.new("'#{name}' is not a valid BOSH id") unless name.bosh_valid_id?
      end

      def jobs
        directory "jobs"
      end

      def packages
        directory "packages"
      end

      def docker_save
        FileUtils.mkdir_p("blobs/docker-images")
        RakeHelper.sh "docker pull #{docker_image}"
        RakeHelper.sh "docker save #{docker_image} > blobs/docker-images/#{image_filename}"
      end

      private
      def package_name
        name
      end

      def image_name
        docker_image.gsub(/\W+/, '_')
      end

      def image_filename
        "#{image_name}.tgz"
      end

      def job_name
        "#{image_name}_image"
      end
    end
  end
end
