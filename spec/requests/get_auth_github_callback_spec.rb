describe AuthenticationsController, 'GET /auth/github/callback', omniauth: true, redis: true do
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
        'indieauth.me' => 'https://me.example.com/',
        'indieauth.client_id' => 'https://client_id.example.com/',
        'indieauth.redirect_uri' => redirect_uri,
        'indieauth.state' => state,
        'indieauth.scope' => [],
        'indieauth.response_type' => 'id'
      }
    end

    before do
      OmniAuth.config.add_mock(:github, info: { nickname: ENV['GITHUB_USER'] })

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
