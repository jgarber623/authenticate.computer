require 'bundler/setup'

Bundler.require(:default, (ENV['RACK_ENV'] || 'development').to_sym)

require File.expand_path('application', __dir__)
