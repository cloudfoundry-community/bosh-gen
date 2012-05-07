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
      method_option :s3, :alias => ["--aws"], :type => :boolean, :desc => "Use AWS S3 bucket for blobstore"
      method_option :atmos, :type => :boolean, :desc => "Use EMC ATMOS for blobstore"
      def new(path)
        flags = { :aws => options["s3"], :atmos => options["atmos"] }
        
        require 'bosh/gen/generators/new_release_generator'
        Bosh::Gen::Generators::NewReleaseGenerator.start([path, flags])
      end
      
      desc "package NAME", "Create a new package"
      method_option :dependencies, :aliases => ['-d'], :type => :array, :desc => "List of package dependencies"
      method_option :files,        :aliases => ['-f', '--src'], :type => :array, :desc => "List of files copy into release"
      def package(name)
        dependencies = options[:dependencies] || []
        files        = options[:files] || []
        require 'bosh/gen/generators/package_generator'
        Bosh::Gen::Generators::PackageGenerator.start([name, dependencies, files])
      end
      
      desc "source NAME", "Downloads a source item into the named project"
      def source(name, uri)
        dir = Dir.mktmpdir
        files = []
        say "Downloading #{uri}..."
        FileUtils.chdir(dir) do
          `wget '#{uri}'`
          files = Dir['*'].map {|f| File.expand_path(f)}
        end

        require 'bosh/gen/generators/package_source_generator'
        Bosh::Gen::Generators::PackageSourceGenerator.start([name, files])
      end
      
      desc "job NAME", "Create a new job"
      method_option :dependencies, :aliases => ['-d'], :type => :array, :desc => "List of package dependencies"
      def job(name)
        dependencies   = options[:dependencies] || []
        require 'bosh/gen/generators/job_generator'
        Bosh::Gen::Generators::JobGenerator.start([name, dependencies])
      end
      
      desc "template JOB FILE_PATH", "Add a Job template (example FILE_PATH: config/httpd.conf)"
      def template(job_name, file_path)
        require 'bosh/gen/generators/job_template_generator'
        Bosh::Gen::Generators::JobTemplateGenerator.start([job_name, file_path])
      end

      desc "manifest NAME PATH UUID", "Creates a deployment manifest based on the release located at PATH"
      method_option :force, :type => :boolean, :desc => "Force override existing target manifest file"
      method_option :addresses, :aliases => ['-a'], :type => :array, :desc => "List of IP addresses available for jobs"
      def manifest(name, release_path, uuid)
        release_path = File.expand_path(release_path)
        ip_addresses = options["addresses"] || []
        flags = { :force => options["force"] || false }
        require 'bosh/gen/generators/deployment_manifest_generator'
        Bosh::Gen::Generators::DeploymentManifestGenerator.start([name, release_path, uuid, ip_addresses, flags])
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
