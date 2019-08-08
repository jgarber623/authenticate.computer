workers 2
threads 5, 5

bind 'unix:///tmp/nginx.socket'

on_worker_fork do
  FileUtils.touch('/tmp/app-initialized')
end

preload_app!

rackup      DefaultRackup
environment ENV['RACK_ENV'] || 'development'
