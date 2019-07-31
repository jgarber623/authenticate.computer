module RSpec
  module OmniAuthHelper
    def self.included(rspec)
      rspec.around(:each, redis: true) do |example|
        OmniAuth.config.mock_auth[:github] = nil

        example.run
      end
    end
  end
end
