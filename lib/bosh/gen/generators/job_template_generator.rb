require 'yaml'
require 'thor/group'

module Bosh::Gen
  module Generators
    class JobTemplateGenerator < Thor::Group
      include Thor::Actions

      argument :job_name
      argument :file_path
      
      def check_root_is_release
        unless File.exist?("jobs") && File.exist?("packages")
          raise Thor::Error.new("run inside a BOSH release project")
        end
      end
      
      def check_job
        raise Thor::Error.new("'#{job_name}' job does not yet exist; either create or fix spelling") unless File.exist?(job_dir(""))
        raise Thor::Error.new("'jobs/#{job_name}/spec' is missing") unless File.exist?(job_dir("spec"))
      end
      
      def check_file_path
        raise Thor::Error.new("'#{file_path}' must be a relative path, such as 'config/httpd.conf'") if file_path[0] == "/"
      end

      def touch_template_erb
        create_file job_template_dir(template_name)
      end
      
      def add_template_to_spec
        current_spec = YAML.load_file(job_dir("spec"))
        current_spec["templates"] ||= {}
        current_spec["templates"][template_name] = file_path
        create_file job_dir("spec"), YAML.dump(current_spec), :force => true
      end
      
      private
      def file_name
        File.basename(file_path)
      end
      
      def template_name
        "#{file_name}.erb"
      end
      
      def job_dir(path)
        File.join("jobs", job_name, path)
      end

      def job_template_dir(path)
        File.join("jobs", job_name, "templates", path)
      end
    end
  end
end
