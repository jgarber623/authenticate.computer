RSpec.describe AuthenticateComputer, 'GET /auth/github/callback', omniauth: true, redis: true do
  context 'when session timeout' do
    it 'renders the 440 view' do
      get '/auth/github/callback', {}, 'rack.session' => {}

      expect(last_response.status).to eq(440)
      expect(last_response.body).to include('Session expired during authentication')
    end
  end

  context 'when user grants access' do
    let(:redirect_uri) { 'https://me.example.com/auth' }
    let(:code) { SecureRandom.hex(32) }
    let(:state) { SecureRandom.hex(32) }

    let(:session_hash) do
      {
        'me' => 'https://me.example.com/',
        'client_id' => 'https://client_id.example.com/',
        'redirect_uri' => redirect_uri,
        'state' => state,
        'scope' => [],
        'response_type' => 'id'
      }
    end

    before do
      OmniAuth.config.add_mock(:github, info: { nickname: ENV.fetch('GITHUB_USER', nil) })

      allow(SecureRandom).to receive(:hex).and_return(code)

      get '/auth/github/callback', {}, 'rack.session' => session_hash
    end

    it 'clears the session' do
      expect(last_request.session.to_h).not_to include(session_hash)
    end

    it 'redirects the user' do
      follow_redirect!

      expect(last_request.url).to eq("#{redirect_uri}?code=#{code}&state=#{state}")
    end
  end
end
