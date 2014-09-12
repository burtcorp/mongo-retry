require 'bundler/setup'
require 'mongo'
require_relative '../lib/mongo/retry'
RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
