describe AuthenticateComputer::App, 'when POST /auth' do
  let(:code) { SecureRandom.hex(32) }
  let(:me) { 'https://me.example.com' }
  let(:client_id) { 'https://client_id.example.com' }
  let(:redirect_uri) { 'https://me.example.com/auth' }

  let :populated_session do
    {
      'me' => "#{me}/",
      'client_id' => "#{client_id}/",
      'redirect_uri' => redirect_uri,
      'state' => SecureRandom.hex(32),
      'scope' => '',
      'response_type' => 'id'
    }
  end

  let(:error) { 'invalid_request' }
  let(:error_description) { 'Authorization code verification could not be completed. Please try again.' }

  before do
    header 'Accept', 'application/json'
  end

  context 'when params[:code] is not present' do
    it 'renders the 400 JSON' do
      post '/auth'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq({ error: error, error_description: 'Parameter code is required and cannot be blank. Please try again.' }.to_json)
    end
  end

  context 'when params[:code] is invalid' do
    it 'renders the 400 JSON' do
      post '/auth', code: 'foo'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq({ error: error, error_description: 'Parameter code value "foo" must match format ^[a-f0-9]{64}$. Please try again.' }.to_json)
    end
  end

  context 'when params[:client_id] is not present' do
    it 'renders the 400 JSON' do
      post '/auth', code: code

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq({ error: error, error_description: 'Parameter client_id is required and cannot be blank. Please try again.' }.to_json)
    end
  end

  context 'when params[:client_id] is invalid' do
    it 'renders the 400 JSON' do
      post '/auth', code: code, client_id: 'foo'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq({ error: error, error_description: 'Parameter client_id value "foo" must match format ^https?://.*. Please try again.' }.to_json)
    end
  end

  context 'when params[:redirect_uri] is not present' do
    it 'renders the 400 JSON' do
      post '/auth', code: code, client_id: client_id

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq({ error: error, error_description: 'Parameter redirect_uri is required and cannot be blank. Please try again.' }.to_json)
    end
  end

  context 'when params[:redirect_uri] is invalid' do
    it 'renders the 400 JSON' do
      post '/auth', code: code, client_id: client_id, redirect_uri: 'foo'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq({ error: error, error_description: 'Parameter redirect_uri value "foo" must match format ^https?://.*. Please try again.' }.to_json)
    end
  end

  context 'when authorization code verification request is invalid' do
    it 'renders the 400 JSON' do
      post '/auth', code: code, client_id: client_id, redirect_uri: redirect_uri

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq({ error: error, error_description: error_description }.to_json)
    end
  end

  context 'when authorization code verification request is valid' do
    before do
      OmniAuth.config.add_mock(:github, info: { nickname: ENV['GITHUB_USER'] })

      allow(SecureRandom).to receive(:hex).and_return(code)

      header 'Accept', 'text/html'
      get '/auth/github/callback', {}, 'rack.session' => populated_session

      header 'Accept', 'application/json'
      post '/auth', code: code, client_id: client_id, redirect_uri: redirect_uri
    end

    it 'renders the response JSON' do
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq({ me: "#{me}/" }.to_json)
    end

    it 'deletes the record from the datastore and renders the 400 JSON' do
      post '/auth', code: code, client_id: client_id, redirect_uri: redirect_uri

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq({ error: error, error_description: error_description }.to_json)
    end
  end
end
