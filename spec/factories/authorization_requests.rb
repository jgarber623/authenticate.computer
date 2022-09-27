FactoryBot.define do
  factory :authorization_request do
    skip_create

    response_type { 'code' }
    client_id { "https://#{Faker::Internet.domain_name}" }
    redirect_uri { "#{client_id}/auth" }
    state { SecureRandom.hex(16) }
    code_challenge { Base64.urlsafe_encode64(Digest::SHA256.hexdigest(SecureRandom.hex(24)), padding: false) }
    code_challenge_method { 'S256' }

    trait :with_scope_param do
      scope { %w[create update delete media].sample }
    end

    trait :with_me_param do
      me { "https://#{Faker::Internet.domain_name}" }
    end

    # factory :authorization_request_with_scope_param, traits: [:with_scope_param]
    # factory :authorization_request_with_me_param, traits: [:with_me_param]
  end
end
