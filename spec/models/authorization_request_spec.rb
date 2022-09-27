require 'rails_helper'

RSpec.describe AuthorizationRequest, type: :model do
  before do
    stub_request(:get, /example\.com/).to_return(status: 200, body: '')
    stub_request(:get, request.client_id).to_return(status: 200, body: %(<link rel="redirect_uri" href="#{request.redirect_uri}">))
  end

  describe 'validations' do
    subject(:request) { build(:authorization_request) }

    it { should validate_presence_of(:response_type) }
    it { should validate_inclusion_of(:response_type).in_array(['code']).with_message('must be “code”') }

    it { should validate_presence_of(:client_id) }
    it { should allow_values('http://example.com', 'https://example.com').for(:client_id) }
    it { should_not allow_values('ftp://example.com').for(:client_id) }

    it { should validate_presence_of(:redirect_uri) }
    it { should allow_values(request.redirect_uri).for(:redirect_uri) }
    it { should validate_inclusion_of(:redirect_uri).in_array([request.redirect_uri]).with_message(/^.+ is not a registered redirect_uri$/) }

    it { should validate_presence_of(:state) }
    it { should validate_length_of(:state).is_at_least(16) }

    it { should validate_presence_of(:code_challenge) }

    it { should validate_presence_of(:code_challenge_method) }
    it { should validate_inclusion_of(:code_challenge_method).in_array(%w[plain S256]).with_message('must be “plain” or “S256”') }

    it { should allow_values('http://example.com', 'https://example.com').for(:me) }
    it { should_not allow_values('ftp://example.com').for(:me) }
  end

  context 'when params[:scope] is set' do
    subject(:request) { build(:authorization_request, scope: 'create+update+delete') }

    it 'returns an array of scopes' do
      expect(request.scopes).to match_array(%w[create update delete])
    end
  end
end
