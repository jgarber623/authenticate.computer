require 'rack/test'
require 'simplecov'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'

OUTER_APP = Rack::Builder.parse_file('config.ru').first

Dir[File.expand_path('../spec/support/**/*.rb', __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include RSpec::OmniAuthHelper
  config.include RSpec::RedisHelper

  def app
    OUTER_APP
  end
end

OmniAuth.config.test_mode = true

WebMock.disable_net_connect!
