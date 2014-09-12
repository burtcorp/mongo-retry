# encoding: utf-8

require 'bundler/gem_helper'

namespace :bundler do
  Bundler::GemHelper.install_tasks
end

desc 'Tag & release the gem'
task :release => [:spec, 'bundler:release']
