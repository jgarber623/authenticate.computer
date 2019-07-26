require 'rack/test'
require 'simplecov'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'

require File.expand_path('../config/environment', __dir__)

Dir[File.expand_path('../spec/support/**/*.rb', __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.include RSpecMixin
end

OmniAuth.config.test_mode = true

WebMock.disable_net_connect!
