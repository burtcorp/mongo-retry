require 'bundler/setup'
require 'mongo'
require_relative '../lib/mongo_retry'
RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
