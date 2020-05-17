RSpec.describe AuthenticateComputer, 'GET /token' do
  let(:error) { 'invalid_request' }

  let(:error_hash) do
    {
      error: error,
      error_description: error_description
    }
  end

  before do
    header 'Accept', 'application/json'
  end

  context 'when request is invalid' do
    let(:error_description) { '400 Bad Request: The request is missing a valid HTTP Authorization header. Please try again.' }

    it 'renders the 400 JSON' do
      get '/token'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq(error_hash.to_json)
    end
  end

  context 'when access token is not found' do
    let(:error_description) { '400 Bad Request: Access token verification could not be completed. Please try again.' }

    it 'renders the 400 JSON' do
      header 'Authorization', 'Bearer foo'
      get '/token'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq(error_hash.to_json)
    end
  end
end
