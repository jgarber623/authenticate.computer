module RSpec
  module RedisHelper
    def self.included(rspec)
      rspec.around(:each, redis: true) do |example|
        example.run
      ensure
        redis.flushall
      end
    end

    private

    def redis
      @redis ||= ::Redis.new
    end
  end
end
