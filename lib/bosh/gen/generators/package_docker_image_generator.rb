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

      def docker_save
        FileUtils.mkdir_p("blobs/docker-images")
        RakeHelper.sh "docker pull #{docker_image}"
        RakeHelper.sh "docker save #{docker_image} > blobs/docker-images/#{image_filename}"
      end

      def jobs
        directory "jobs"
      end

      def packages
        directory "packages"
      end

      def readme
        say "Next steps:", :green
        say <<-README.gsub(/^        /, '')
          1. To use this BOSH release, first upload it and the docker release to your BOSH:
            bosh upload release https://bosh.io/releases/cloudfoundry-community/consul-docker
            bosh upload release https://bosh.io/d/github.com/cf-platform-eng/docker-boshrelease

          2. To use the docker image, your deployment job needs to start with the following:

            jobs:
            - name: some_job
            templates:
              # run docker daemon
              - {name: docker, release: docker}
              # warm docker image cache from bosh package
              - {name: #{job_name}, release: #{project_name_hyphenated}}

          3. To simply run a single container, try the 'containers' job from 'docker' release

            https://github.com/cloudfoundry-community/consul-docker-boshrelease/blob/master/templates/jobs.yml#L18-L40


        README
      end

      private
      def root_path
        File.expand_path("../../../../..", __FILE__)
      end

      def project_name
        @project_name ||= root_path.gsub(/-(?:boshrelease|release)$/, '')
      end

      def project_name_hyphenated
        project_name.gsub(/[^A-Za-z0-9]+/, '-')
      end

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
