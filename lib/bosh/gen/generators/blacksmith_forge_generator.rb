require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class BlacksmithForgeGenerator < Thor::Group
      include Thor::Actions

      argument :name

      def self.source_root
        File.join(File.dirname(__FILE__), "blacksmith_forge_generator", "templates")
      end

      # FYI, bosh-gen (the CLI) will eventually call Thor, telling it to `start()`
      # Don't bother looking for a start() function anywhere; Thor just calls all of
      # the public methods of this class.

      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end

      def check_name
        raise Thor::Error.new("'#{name}' is not a valid BOSH id") unless "#{name}-blacksmith-plans".bosh_valid_id?
      end

      def copy_files
        generator_job_templates_path = File.join(self.class.source_root, "jobs/%job_name%")
        directory "jobs/%job_name%", "jobs/#{job_name}"
      end

      private
      def job_name
        "#{name}-blacksmith-plans"
      end
    end
  end
end
