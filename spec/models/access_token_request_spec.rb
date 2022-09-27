require 'rails_helper'

RSpec.describe AccessTokenRequest, type: :model do
  describe 'validations' do
    subject(:request) { build(:access_token_request) }

    it { should validate_presence_of(:grant_type) }
    it { should validate_inclusion_of(:grant_type).in_array(['authorization_code']) }

    it { should validate_presence_of(:code) }

    it { should validate_presence_of(:client_id) }
    it { should allow_values('http://example.com', 'https://example.com').for(:client_id) }
    it { should_not allow_values('ftp://example.com').for(:client_id) }

    it { should validate_presence_of(:redirect_uri) }
    it { should allow_values('http://example.com', 'https://example.com').for(:redirect_uri) }
    it { should_not allow_values('ftp://example.com').for(:redirect_uri) }

    it { should validate_presence_of(:code_verifier) }
  end
end
