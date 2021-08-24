source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.4'

gem 'bootsnap', '~> 1.7', require: false
gem 'brakeman'
gem 'http', '~> 5.0'
gem 'jbuilder', '~> 2.11'
gem 'indieweb-endpoints', '~> 6.1'
gem 'lograge', '~> 0.11.2'
gem 'micromicro', '~> 1.1'
gem 'pg', '~> 1.2'
gem 'puma', '~> 5.4'
gem 'rails', '~> 6.1'
gem 'redis', '~> 4.4'
gem 'sassc-rails', '~> 2.1'
gem 'tzinfo-data', '~> 1.2021'
gem 'webpacker', '~> 5.4'

group :development, :test do
  gem 'bundler-audit'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'foreman'
  gem 'pry-byebug'
  gem 'rspec_junit_formatter', require: false
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda-matchers'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'rack-mini-profiler'
end

group :test do
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
  gem 'webmock'
end
