# Copyright (c) 2012-2014 Stark & Wayne, LLC

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)

require "rubygems"
require "bundler"
Bundler.setup(:default, :test)

$:.unshift(File.expand_path("../../lib", __FILE__))

require "rspec/core"

require "bosh/gen/settings"

# load all files in spec/support/* (but not lower down)
Dir[File.dirname(__FILE__) + '/support/*'].each do |path|
  require path unless File.directory?(path)
end

def fixture_release_path(name)
  File.expand_path("../fixtures/releases/#{name}/", __FILE__)
end

RSpec.configure do |c|
  c.before do
    extend GeneratorSpecHelper
    setup_universe
  end
  c.color = true
end
