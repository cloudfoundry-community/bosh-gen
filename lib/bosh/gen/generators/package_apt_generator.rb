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
        create_file package_dir("packaging") do
          <<-SHELL.gsub(/^\s{10}/, '')
          set -e # exit immediately if a simple command exits with a non-zero status
          set -u # report the usage of uninitialized variables
          
          # Available variables
          # $BOSH_COMPILE_TARGET - where this package & spec'd source files are available
          # $BOSH_INSTALL_TARGET - where you copy/install files to be included in package
          
          mkdir -p $BOSH_INSTALL_TARGET/apt
          
          for DEB in $(ls -1 apt/#{name}/*.deb); do
            echo "Installing $(basename $DEB)"
            dpkg -x $DEB $BOSH_INSTALL_TARGET/apt
          done
          
          cp -a apt/#{name}/profile.sh $BOSH_INSTALL_TARGET/
          SHELL
        end
      end

      def package_specification
        src_files = ["apt/#{name}/profile.sh", "apt/#{name}/*.deb"]
        config = { "name" => name, "dependencies" => dependencies, "files" => src_files }
        create_file package_dir("spec"), YAML.dump(config)
      end

      def common_helpers
        directory 'src/apt'
        chmod 'src/apt/fetch_debs.sh', 0755
      end

      def vagrantfile
        copy_file 'Vagrantfile'
      end

      def show_instructions
        say "Next steps:", :green
        say <<-README.gsub(/^        /, '')
          1. Edit src/apt/#{name}/aptfile to specify list of debian packages to install
          2. Provision vagrant and run script to fetch debian packages:

            vagrant up
            vagrant ssh -c '/vagrant/src/apt/fetch_debs.sh #{name}'
            vagrant destroy

          You can search for aptitude debian packages using apt-cache:

            vagrant ssh -c 'apt-cache search #{name} | sort'
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
