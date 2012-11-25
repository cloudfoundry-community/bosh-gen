require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class MicroJobGenerator < Thor::Group
      include Thor::Actions

      argument :job_name

      def self.source_root
        File.join(File.dirname(__FILE__), "micro_job_generator", "templates")
      end
      
      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end
      
      def create_job
        directory "jobs/micro", "jobs/#{job_name}"
        chmod "jobs/#{job_name}/prepare", 0755
      end
      
      def prepare_spec_defaults_all_jobs
        jobs = Dir[File.expand_path("jobs/*")].map {|job| File.basename(job) } - [job_name]
        spec = { "jobs" => jobs }
        create_file "jobs/#{job_name}/prepare_spec", YAML.dump(spec)
      end
      
      def gitignore
        append_file ".gitignore", <<-IGNORE.gsub(/^\s{8}/, '')
        jobs/#{job_name}/monit
        jobs/#{job_name}/spec
        jobs/#{job_name}/templates/
        IGNORE
      end
      
      def readme
        say ""
        say "Edit "; say "jobs/#{job_name}/prepare_spec ", :yellow
          say "with ordered list of jobs to include"
        say "in micro job. The order of jobs implicitly specifies the order in"
        say "which they are started."
        say ""
        say ""
      end
    end
  end
end
