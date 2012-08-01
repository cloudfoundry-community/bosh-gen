require "bosh/gen/cli"

module GeneratorSpecHelper
  def setup_universe
    @tmp_root      = File.expand_path("../../tmp", __FILE__)
    @home_path     = File.join(@tmp_root, "home")
    @fixtures_path = File.expand_path('../../fixtures', __FILE__)
    FileUtils.rm_rf   @tmp_root
    FileUtils.mkdir_p @home_path
    ENV['HOME'] = @home_path
  end

  def setup_project_release(name)
    release_path = File.join(@fixtures_path, "releases", name)
    FileUtils.cp_r(release_path, @tmp_root)
    @active_project_folder = File.join(@tmp_root, name)
  end

  def generate_job(job)
    capture_stdios do
      Bosh::Gen::Command.start(["job", job])
    end
  end

  # Test that a file exists in job
  #   job_file_exists "mywebapp", "monit"
  #   job_file_exists "mywebapp", "templates", "mywebapp_ctl", :executable => true
  def job_file_exists(*args)
    if args.last.is_a?(Hash)
      options = args.pop
    end
    path = File.join(["jobs"] + args) # jobs/JOBNAME/monit
    File.exist?(path).must_equal(true, "#{path} not created")
    if options && options[:executable]
      File.executable?(path).must_equal(true, "#{path} not executable")
    end
  end

  def setup_active_project_folder project_name
    @active_project_folder = File.join(@tmp_root, project_name)
    @project_name = project_name
  end

  def in_tmp_folder(&block)
    FileUtils.chdir(@tmp_root, &block)
  end

  def in_project_folder(&block)
    project_folder = @active_project_folder || @tmp_root
    FileUtils.chdir(project_folder, &block)
  end

  def in_home_folder(&block)
    FileUtils.chdir(@home_path, &block)
  end

  def capture_stdios(input = nil, &block)
    require 'stringio'
    org_stdin, $stdin = $stdin, StringIO.new(input) if input
    org_stdout, $stdout = $stdout, StringIO.new
    org_stderr, $stderr = $stdout, StringIO.new
    yield
    return [$stdout.string, $stderr.string]
  ensure
    $stderr = org_stderr
    $stdout = org_stdout
    $stdin = org_stdin
  end

  def get_command_output
    strip_color_codes(File.read(@stdout)).chomp
  end

  def strip_color_codes(text)
    text.gsub(/\e\[\d+m/, '')
  end
end
