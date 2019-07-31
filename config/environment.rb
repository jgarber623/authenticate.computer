app = File.expand_path('../app', __dir__)
$LOAD_PATH.unshift(app) unless $LOAD_PATH.include?(app)

require 'bundler/setup'

Bundler.require(:default, (ENV['RACK_ENV'] || 'development').to_sym)

require 'models/error'

require 'services/endpoint_discovery_service'
require 'services/http_request_service'

require 'helpers/application_helper'

require 'controllers/application_controller'
require 'controllers/authentications_controller'
require 'controllers/pages_controller'
require 'controllers/tokens_controller'
