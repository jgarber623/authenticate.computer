namespace :redis do
  desc 'Delete all keys from all Redis databases'
  task reset: :environment do
    if Rails.env.development?
      Redis.current.flushall
      puts '[ redis:reset ] ✨ All Redis databases were flushed!'
    else
      puts '🚨 redis:reset may only be run in a development environment!'
    end
  end
end
