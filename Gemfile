ruby '2.6.6'

source 'https://rubygems.org'

gem 'activesupport', '~> 6.0', require: 'active_support/core_ext/object/blank'
gem 'addressable', '~> 2.7', require: 'addressable/uri'
gem 'breakpoint', '~> 2.7'
gem 'http', '~> 4.4'
gem 'indieweb-endpoints', '~> 4.0'
gem 'omniauth', '~> 1.9'
gem 'omniauth-github', '~> 1.3'
gem 'puma', '~> 4.3'
gem 'rack', '~> 2.2'
gem 'rack-protection', '~> 2.0'
gem 'redis', '~> 4.2'
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
  gem 'reek', '~> 6.0', require: false
  gem 'rspec', '~> 3.9'
  gem 'rubocop', '~> 0.89.1', require: false
  gem 'rubocop-performance', '~> 1.7', require: false
  gem 'rubocop-rspec', '~> 1.43', require: false
  gem 'webmock', '~> 3.8', require: false
end

group :development do
  gem 'shotgun', '~> 0.9.2'
end

group :test do
  gem 'simplecov', '~> 0.19.0', require: false
  gem 'simplecov-console', '~> 0.7.2', require: false
end
