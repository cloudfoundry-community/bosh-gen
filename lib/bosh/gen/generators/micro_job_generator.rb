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
        chmod "jobs/micro/prepare", 0755
      end
      
      def prepare_spec_defaults_all_jobs
        jobs = Dir[File.expand_path("jobs/*")].map {|job| File.basename(job) } - ['micro']
        spec = { "jobs" => jobs }
        create_file "jobs/micro/prepare_spec", YAML.dump(spec)
      end
      
      def gitignore
        append_file ".gitignore", <<-IGNORE.gsub(/^\s{8}/, '')
        jobs/micro*/monit
        jobs/micro*/spec
        jobs/micro*/templates/
        IGNORE
      end
      
      def readme
        say ""
        say "Edit "; say "jobs/micro/prepare_spec ", :yellow
          say "with ordered list of jobs to include"
        say "in micro job. The order of jobs implicitly specifies the order in"
        say "which they are started."
        say ""
        say ""
      end
      
    end
  end
end
