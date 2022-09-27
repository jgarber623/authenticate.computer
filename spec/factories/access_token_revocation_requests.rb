FactoryBot.define do
  factory :access_token_revocation_request do
    skip_create

    action { 'revoke' }
    # token {}
  end
end
