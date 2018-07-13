lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

env = (ENV['RACK_ENV'] || 'development').to_sym

require 'bundler/setup'

Bundler.require(:default, env)

require 'authenticate_computer'
