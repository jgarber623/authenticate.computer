describe AuthenticateComputer::App do
  context 'when GET /auth/github/callback' do
    let(:me) { 'https://me.example.com' }
    let(:client_id) { 'https://client_id.example.com' }
    let(:redirect_uri) { 'https://me.example.com/auth' }
    let(:state) { SecureRandom.hex(32) }

    let :populated_session do
      {
        'me' => "#{me}/",
        'client_id' => "#{client_id}/",
        'redirect_uri' => redirect_uri,
        'state' => state,
        'scope' => '',
        'response_type' => 'id'
      }
    end

    let(:code) { SecureRandom.hex(32) }

    before do
      OmniAuth.config.mock_auth[:github] = nil
    end

    context 'when session timeout' do
      before do
        OmniAuth.config.add_mock(:github, info: { nickname: ENV['GITHUB_USER'] })
      end

      it 'renders the 440 view' do
        get '/auth/github/callback', {}, 'rack.session' => {}

        expect(last_response.status).to eq(440)
        expect(last_response.body).to include('Session expired during authentication')
      end
    end

    context 'when user grants access' do
      before do
        OmniAuth.config.add_mock(:github, info: { nickname: ENV['GITHUB_USER'] })

        allow(SecureRandom).to receive(:hex).and_return(code)

        get '/auth/github/callback', {}, 'rack.session' => populated_session
      end

      it 'clears the session' do
        expect(last_request.session.to_h).not_to include(populated_session)
      end

      it 'redirects the user' do
        expect(last_response.redirect?).to be(true)

        follow_redirect!

        expect(last_request.url).to eq("#{redirect_uri}?code=#{code}&state=#{state}")
      end
    end
  end
end
