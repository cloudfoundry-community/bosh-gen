require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class PackageGenerator < Thor::Group
      include Thor::Actions

      argument :name
      argument :dependencies, :type => :array
      argument :files, :type => :array

      BLOB_FILE_MIN_SIZE=20_000 # files over 20k are blobs

      def self.source_root
        File.join(File.dirname(__FILE__), "package_generator", "templates")
      end

      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end

      def check_name
        raise Thor::Error.new("'#{name}' is not a vaild BOSH id") unless name.bosh_valid_id?
      end

      def warn_missing_dependencies
        dependencies.each do |d|
          raise Thor::Error.new("dependency '#{d}' is not a vaild BOSH id") unless d.bosh_valid_id?
          unless File.exist?(File.join("packages", d))
            say_status "warning", "missing dependency '#{d}'", :yellow
          end
        end
      end

      def packaging
        create_file package_dir("packaging") do
          packaging = <<-SHELL.gsub(/^\s{10}/, '')
          set -e # exit immediately if a simple command exits with a non-zero status
          set -u # report the usage of uninitialized variables
          
          export HOME=/var/vcap
          
          SHELL

          dependencies.each do |package|
            packaging << "PATH=/var/vcap/packages/#{package}/bin:$PATH\n"
          end

          tarballs_in_files.each do |tarball_file|
            package_file = File.basename(tarball_file)
            unpacked_path = unpacked_path_for_tarball(tarball_file)
            
            packaging << <<-SHELL.gsub(/^\s{12}/, '')
            
            tar xzf #{name}/#{package_file}
            cd #{unpacked_path}
            ./configure --prefix=${BOSH_INSTALL_TARGET}
            make
            make install
            SHELL
          end
          packaging
        end

        create_file package_dir("pre_packaging") do
          <<-SHELL.gsub(/^\s{10}/, '')
          set -e # exit immediately if a simple command exits with a non-zero status
          set -u # report the usage of uninitialized variables
          
          SHELL
        end
      end

      # Copy the local source files into src or blobs
      # * into src/NAME/filename (if < 20k) or
      # * into blobs/NAME/filename (if >= 20k)
      # Skip a file if:
      # * filename already exists as a blob in blobs/NAME/filename
      # * file doesn't exist
      def copy_src_files
        files.each do |file|
          file_path = File.expand_path(file)
          unless File.exist?(file_path)
            say "Skipping unknown file #{file_path}", :red
            next
          end
          
          size      = File.size(file_path)
          file_name = File.basename(file_path)
          src_file  = src_dir(file_name)
          blob_file = blob_dir(file_name)
          if File.exist?(blob_file)
            say "Blob '#{file_name}' exists as a blob, skipping..."
          else
            # if < 20k, put in src/, else blobs/
            target = size >= BLOB_FILE_MIN_SIZE ? blob_file : src_file
            copy_file File.expand_path(file_path), target
          end
        end
      end
      
      def package_specification
        src_files = files.map {|f| "#{name}/#{File.basename(f)}"}
        config = { "name" => name, "dependencies" => dependencies, "files" => src_files }
        create_file package_dir("spec"), YAML.dump(config)
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
      
      # Run a command in git.
      #
      # ==== Examples
      #
      #   git :init
      #   git :add => "this.file that.rb"
      #   git :add => "onefile.rb", :rm => "badfile.cxx"
      #
      def git(commands={})
        if commands.is_a?(Symbol)
          run "git #{commands}"
        else
          commands.each do |cmd, options|
            run "git #{cmd} #{options}"
          end
        end
      end

      # Returns all .tar.gz in the files list
      def tarballs_in_files
        files.select { |file| file =~ /.(?:tar.gz|tgz)/  }
      end

      # If primary_package_file was mysql's client-5.1.62-rel13.3-435-Linux-x86_64.tar.gz
      # then returns "client-5.1.62-rel13.3-435-Linux-x86_64"
      #
      # Assumes that first line of "tar tfz TARBALL" is the unpacking path
      def unpacked_path_for_tarball(tarball_path)
        file = `tar tfz #{tarball_path} | head -n 1`
        File.basename(file.strip)
      end
    end
  end
end
