require 'barnes'

workers 2
threads 5, 5

bind 'unix:///tmp/nginx.socket'

before_fork do
  Barnes.start
end

on_worker_fork do
  FileUtils.touch('/tmp/app-initialized')
end

preload_app!

rackup      DefaultRackup
environment ENV['RACK_ENV'] || 'development'
