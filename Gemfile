ruby '2.6.1'

source 'https://rubygems.org'

gem 'puma', '~> 3.12'
gem 'redis', '~> 4.1'
gem 'sinatra', '~> 2.0'
gem 'sinatra-param', git: 'https://github.com/jgarber623/sinatra-param', tag: 'v2.0.0'

group :development, :test do
  gem 'dotenv', '~> 2.7'
  gem 'rack-test', '~> 1.1'
  gem 'rake', '~> 12.3'
  gem 'rspec', '~> 3.8'
  gem 'rubocop', '~> 0.67.2', require: false
  gem 'rubocop-rspec', '~> 1.32', require: false
end

group :development do
  gem 'shotgun', '~> 0.9.2'
end

group :test do
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'simplecov-console', '~> 0.4.2', require: false
end
