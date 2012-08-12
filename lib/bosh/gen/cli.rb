require "thor"

# bosh_cli libraries
module Bosh; end
require "cli/config" 
require "cli/core_ext"

require 'bosh/gen/models'

module Bosh
  module Gen
    class Command < Thor
      include Thor::Actions
    
      desc "new PATH", "Creates a new BOSH release"
      method_option :s3, :alias => ["--aws"], :type => :boolean, 
        :desc => "Use AWS S3 bucket for blobstore"
      method_option :atmos, :type => :boolean, 
        :desc => "Use EMC ATMOS for blobstore"
      def new(path)
        flags = { :aws => options["s3"], :atmos => options["atmos"] }
        
        require 'bosh/gen/generators/new_release_generator'
        Bosh::Gen::Generators::NewReleaseGenerator.start([path, flags])
      end
      
      desc "package NAME", "Create a new package"
      method_option :dependencies, :aliases => ['-d'], :type => :array, 
        :desc => "List of package dependencies"
      method_option :files,        :aliases => ['-f', '--src'], :type => :array, 
        :desc => "List of files copy into release"
      def package(name)
        dependencies = options[:dependencies] || []
        files        = options[:files] || []
        require 'bosh/gen/generators/package_generator'
        Bosh::Gen::Generators::PackageGenerator.start(
          [name, dependencies, files])
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

      desc "micro", "Create a micro job - a collection of all jobs and packages"
      def micro
        require 'bosh/gen/generators/micro_job_generator'
        Bosh::Gen::Generators::MicroJobGenerator.start([])
      end

      desc "template JOB FILE_PATH", 
        "Add a Job template (example FILE_PATH: config/httpd.conf)"
      def template(job_name, file_path)
        require 'bosh/gen/generators/job_template_generator'
        Bosh::Gen::Generators::JobTemplateGenerator.start([job_name, file_path])
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

      desc "manifest NAME PATH", 
        "Creates a deployment manifest based on the release located at PATH"
      method_option :force, :type => :boolean, 
        :desc => "Force override existing target manifest file"
      method_option :addresses, :aliases => ['-a'], :type => :array, 
        :desc => "List of IP addresses available for jobs"
      method_option :disk, :aliases => ['-d'], :type => :string, 
        :desc => "Attach persistent disks to VMs of specific size, e.g. 8196"
      def manifest(name, release_path)
        release_path = File.expand_path(release_path)
        ip_addresses = options["addresses"] || []
        flags = { :force => options["force"] || false, :disk => options[:disk] }
        require 'bosh/gen/generators/deployment_manifest_generator'
        Bosh::Gen::Generators::DeploymentManifestGenerator.start(
          [name, release_path, ip_addresses, flags])
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
