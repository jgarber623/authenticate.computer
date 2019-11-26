ruby '2.6.5'

source 'https://rubygems.org'

gem 'activesupport', '~> 6.0', require: 'active_support/core_ext/object/blank'
gem 'addressable', '~> 2.7', require: 'addressable/uri'
gem 'breakpoint', '~> 2.7'
gem 'http', '~> 5.0.0.pre'
gem 'indieweb-endpoints', '~> 1.0'
gem 'omniauth', '~> 1.9'
gem 'omniauth-github', '~> 1.3'
gem 'puma', '~> 4.2'
gem 'rack', '~> 2.0'
gem 'rack-protection', '~> 2.0'
gem 'redis', '~> 4.1'
gem 'sass', '~> 3.7'
gem 'sass-globbing', '~> 1.1'
gem 'sinatra', '~> 2.0'
gem 'sinatra-asset-pipeline', '~> 2.2', require: 'sinatra/asset_pipeline'
gem 'sinatra-contrib', '~> 2.0'
gem 'sinatra-param', github: 'jgarber623/sinatra-param', tag: 'v3.2.0'
gem 'sinatra-partial', '~> 1.0'

group :development, :test do
  gem 'dotenv', '~> 2.7', require: 'dotenv/load'
  gem 'rack-test', '~> 1.1', require: false
  gem 'rake', '~> 12.3'
  gem 'reek', '~> 5.5', require: false
  gem 'rspec', '~> 3.9'
  gem 'rubocop', '~> 0.76.0', require: false
  gem 'rubocop-performance', '~> 1.5', require: false
  gem 'rubocop-rspec', '~> 1.37', require: false
  gem 'webmock', '~> 3.7', require: false
end

group :development do
  gem 'shotgun', '~> 0.9.2'
end

group :test do
  gem 'simplecov', '~> 0.17.1', require: false
  gem 'simplecov-console', '~> 0.6.0', require: false
end
