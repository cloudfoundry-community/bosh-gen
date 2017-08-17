require "thor"

require "fileutils"
require "bosh/gen/bosh-cli-commands"
require "bosh/gen/bosh-config"
require "bosh/gen/core-ext"

module Bosh
  module Gen
    class Command < Thor
      include Thor::Actions

      desc "new PATH", "Creates a new BOSH release"
      def new(path)
        require 'bosh/gen/generators/new_release_generator'
        Bosh::Gen::Generators::NewReleaseGenerator.start([path])
      end

      desc "package NAME", "Create a new package"
      method_option :apt, :type => :boolean,
        :desc => "Create package using debian/ubuntu apt .debs"
      method_option :docker_image, :type => :string,
        :desc => "Create package from remote docker image"
      method_option :dependencies, :aliases => ['-d'], :type => :array,
        :desc => "List of package dependencies"
      method_option :files,        :aliases => ['-f'], :type => :array,
        :desc => "List of files copy into release"
      method_option :src,        :aliases => ['-s'], :type => :array,
        :desc => "List of existing sources to use, e.g. --src 'myapp/**/*'"
      def package(name)
        dependencies = options[:dependencies] || []
        if options[:apt]
          require 'bosh/gen/generators/package_apt_generator'
          Bosh::Gen::Generators::PackageAptGenerator.start([name, dependencies])
        elsif options[:docker_image]
          docker_image = options[:docker_image]
          require 'bosh/gen/generators/package_docker_image_generator'
          Bosh::Gen::Generators::PackageDockerImageGenerator.start([name, docker_image])
        else
          files        = options[:files] || []
          sources      = options[:src] || []
          require 'bosh/gen/generators/package_generator'
          Bosh::Gen::Generators::PackageGenerator.start(
            [name, dependencies, files, sources])
        end
      end

      desc "source NAME", "Downloads a source item into the named project"
      method_option :blob, :aliases => ['-b'], :type => :boolean,
        :desc => "Store file in blobstore"
      def source(name, uri)
        flags = { :blob => options[:blob] || false }
        dir = Dir.mktmpdir
        files = []
        if File.exist?(uri)
          files = [uri]
        else
          say "Downloading #{uri}..."
          FileUtils.chdir(dir) do
            `wget '#{uri}'`
            files = Dir['*'].map {|f| File.expand_path(f)}
          end
        end

        require 'bosh/gen/generators/package_source_generator'
        Bosh::Gen::Generators::PackageSourceGenerator.start(
          [name, files, flags])
      end

      desc "job NAME", "Create a new job"
      method_option :dependencies, :aliases => ['-d'], :type => :array,
        :desc => "List of package dependencies"
      def job(name)
        dependencies = options[:dependencies] || []
        require 'bosh/gen/generators/job_generator'
        Bosh::Gen::Generators::JobGenerator.start([name, dependencies, 'simple'])
      end

      desc "errand NAME", "Create a new errand"
      method_option :dependencies, :aliases => ['-d'], :type => :array,
        :desc => "List of package dependencies"
      def errand(name)
        dependencies = options[:dependencies] || []
        require 'bosh/gen/generators/errand_generator'
        Bosh::Gen::Generators::ErrandGenerator.start([name, dependencies])
      end

      desc "template JOB FILE_PATH",
        "Add a Job template (example FILE_PATH: config/httpd.conf)"
      def template(job_name, file_path)
        require 'bosh/gen/generators/job_template_generator'
        Bosh::Gen::Generators::JobTemplateGenerator.start([job_name, file_path])
      end

      desc "forge NAME",
        "Creates a Blacksmith Forge job to get you up and running"
      def forge(job_name)
        require 'bosh/gen/generators/blacksmith_forge_generator'
        Bosh::Gen::Generators::BlacksmithForgeGenerator.start([job_name])
      end

      desc "extract-job SOURCE_PACKAGE_PATH",
        "Extracts a job from another release and all its " +
        "dependent packages and source"
      def extract_job(source_package_path)
        source_package_path = File.expand_path(source_package_path)
        require 'bosh/gen/generators/extract_job_generator'
        Bosh::Gen::Generators::ExtractJobGenerator.start([source_package_path])
      end

      desc "extract-pkg SOURCE_PACKAGE_PATH",
        "Extracts a package from another release and all its " +
        "dependent packages and sources"
      def extract_pkg(source_package_path)
        source_package_path = File.expand_path(source_package_path)
        require 'bosh/gen/generators/extract_package_generator'
        Bosh::Gen::Generators::ExtractPackageGenerator.start([source_package_path])
      end

      no_tasks do
        def cyan; "\033[36m" end
        def clear; "\033[0m" end
        def bold; "\033[1m" end
        def red; "\033[31m" end
        def green; "\033[32m" end
        def yellow; "\033[33m" end
      end
    end
  end
end
