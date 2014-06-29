#!/usr/bin/env rake
require "bundler/gem_tasks"

require "rspec/core/rake_task"


desc "Run Tests"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/unit/**/*_spec.rb"
  t.rspec_opts = %w(--format progress --color)
end

task :default => :spec
