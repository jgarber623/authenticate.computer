ruby '2.5.1'

source 'https://rubygems.org'

gem 'addressable', '~> 2.5', '>= 2.5.2', require: 'addressable/uri'
gem 'sinatra', '~> 2.0', '>= 2.0.3'

group :development, :test do
  gem 'rack-test', '~> 1.1'
  gem 'rake', '~> 12.3', '>= 12.3.1'
  gem 'rspec', '~> 3.7'
  gem 'rubocop', '~> 0.60.0', require: false
  gem 'rubocop-rspec', '~> 1.27', require: false
end

group :development do
  gem 'shotgun', '~> 0.9.2'
end

group :test do
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'simplecov-console', '~> 0.4.2', require: false
end
