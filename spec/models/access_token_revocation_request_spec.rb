require 'rails_helper'

RSpec.describe AccessTokenRevocationRequest, type: :model do
  describe 'validations' do
    subject(:request) { build(:access_token_revocation_request) }

    it { should validate_presence_of(:action) }
    it { should validate_inclusion_of(:action).in_array(['revoke']) }

    it { should validate_presence_of(:token) }
  end
end
