require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class MicroJobGenerator < Thor::Group
      include Thor::Actions

      def self.source_root
        File.join(File.dirname(__FILE__), "micro_job_generator", "templates")
      end
      
      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end
      
      def create_job
        directory "jobs/micro"
      end
      
      def gitignore
        append_file ".gitignore", <<-IGNORE.gsub(/^\s{8}/, '')
        jobs/micro*/monit
        jobs/micro*/spec
        jobs/micro*/templates/
        IGNORE
      end
      
    end
  end
end
