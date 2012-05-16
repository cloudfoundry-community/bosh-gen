require "minitest/spec"
require "minitest-colorize"

module FixtureHelpers
  def fixture_release_path(name)
    File.expand_path("../fixtures/releases/#{name}/", __FILE__)
  end
end

MiniTest::Spec.send(:include, FixtureHelpers)