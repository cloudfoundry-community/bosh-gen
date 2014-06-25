require "minitest/spec"
require "minitest-colorize"

require "bosh/gen/settings"

# load all files in spec/support/* (but not lower down)
Dir[File.dirname(__FILE__) + '/support/*'].each do |path|
  require path unless File.directory?(path)
end

module FixtureHelpers
  def fixture_release_path(name)
    File.expand_path("../fixtures/releases/#{name}/", __FILE__)
  end
end

MiniTest::Spec.send(:include, FixtureHelpers)
