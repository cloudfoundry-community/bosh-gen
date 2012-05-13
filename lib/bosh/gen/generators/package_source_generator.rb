require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class PackageSourceGenerator < Thor::Group
      include Thor::Actions

      argument :package_name
      argument :file_paths
      argument :flags, :type => :hash
      
      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end
      
      def check_package
        raise Thor::Error.new("'#{package_name}' package does not yet exist; either create or fix spelling") unless File.exist?(package_dir(""))
        raise Thor::Error.new("'packages/#{package_name}/spec' is missing") unless File.exist?(package_dir("spec"))
      end
      
      def add_filenames_to_spec
        current_spec = YAML.load_file(package_dir("spec"))
        current_spec["files"] ||= []
        file_paths.each do |path|
          current_spec["files"] << File.join(package_name, File.basename(path))
        end
        create_file package_dir("spec"), YAML.dump(current_spec), :force => true
      end
      
      def copy_files
        source_paths << File.dirname(file_paths.first) # file_paths all in same folder
        file_paths.each do |path|
          copy_file path, source_dir(File.basename(path))
        end
      end
      
      # Add a guess about the packaging/compilation of the file
      def packaging
        packaging_for_files = ""
        file_paths.each do |path|
          filename = File.basename(path)
          if filename =~ /^(.*)(\.tar\.gz|\.tgz)$/
            package_dir = $1
            # assume its a standard installable source package
            packaging_for_files += <<-BASH.gsub(/^\s{12}/, '')
            tar xfz #{package_name}/#{filename}
            (
              cd #{package_dir}
              ./configure --prefix=$BOSH_INSTALL_TARGET
              make
              make install
            )
            
            BASH
          end
        end
        append_file "packages/#{package_name}/packaging", packaging_for_files
      end
      
      def readme
        if flags[:blob]
          say_status "readme", "Upload blobs with 'bosh upload blobs'"
        end
      end
      
      private
      def package_dir(path)
        File.join("packages", package_name, path)
      end

      def source_dir(path)
        if flags[:blob]
          File.join("blobs", package_name, path)
        else
          File.join("src", package_name, path)
        end
      end
    end
  end
end
