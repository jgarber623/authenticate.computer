ruby '2.6.3'

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

gem 'addressable', '~> 2.6', require: 'addressable/uri'
gem 'indieweb-endpoints', '~> 0.7.0'
gem 'sinatra', '~> 2.0'
gem 'sinatra-asset-pipeline', '~> 2.2', require: 'sinatra/asset_pipeline'
gem 'sinatra-param', github: 'jgarber623/sinatra-param', tag: 'v3.1.0'

group :development, :test do
  gem 'rack-test', '~> 1.1'
  gem 'rake', '~> 12.3'
  gem 'reek', '~> 5.4'
  gem 'rspec', '~> 3.8'
  gem 'rubocop', '~> 0.73.0', require: false
  gem 'rubocop-performance', '~> 1.4', require: false
  gem 'rubocop-rspec', '~> 1.33', require: false
end

group :development do
  gem 'shotgun', '~> 0.9.2'
end

group :test do
  gem 'simplecov', '~> 0.17.0', require: false
  gem 'simplecov-console', '~> 0.5.0', require: false
end
