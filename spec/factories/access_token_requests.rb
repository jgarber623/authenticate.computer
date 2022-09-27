FactoryBot.define do
  factory :access_token_request do
    skip_create

    grant_type { 'authorization_code' }
    code { SecureRandom.hex(32) }
    client_id { "https://#{Faker::Internet.domain_name}" }
    redirect_uri { "#{client_id}/auth" }
    code_verifier { SecureRandom.hex(24) }
  end
end
