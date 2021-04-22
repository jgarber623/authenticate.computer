ruby '2.6.7'

source 'https://rubygems.org'

gem 'activesupport', '~> 6.1', require: 'active_support/core_ext/object/blank'
gem 'addressable', '~> 2.7', require: 'addressable/uri'
gem 'barnes', '~> 0.0.9', require: false
gem 'breakpoint', '~> 2.7'
gem 'http', '~> 4.4'
gem 'indieweb-endpoints', '~> 5.0'
gem 'omniauth', '~> 2.0'
gem 'omniauth-github', '~> 2.0'
gem 'puma', '~> 5.2'
gem 'rack', '~> 2.2'
gem 'rack-protection', '~> 2.0'
gem 'redis', '~> 4.2'
gem 'sass', '~> 3.7'
gem 'sass-globbing', '~> 1.1'
gem 'sinatra', '~> 2.0'
gem 'sinatra-asset-pipeline', '~> 2.2', require: 'sinatra/asset_pipeline'
gem 'sinatra-contrib', '~> 2.0'
gem 'sinatra-param', github: 'jgarber623/sinatra-param', tag: 'v3.4.0'
gem 'sinatra-partial', '~> 1.0'

group :development, :test do
  gem 'bundler-audit'
  gem 'dotenv', require: 'dotenv/load'
  gem 'rack-test', require: false
  gem 'rake'
  gem 'reek', require: false
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rake', require: false
  gem 'rubocop-rspec', require: false
  gem 'webmock', require: false
end

group :development do
  gem 'shotgun'
end

group :test do
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
end
