describe AuthenticateComputer::App, 'when POST /auth/github' do
  let(:authenticity_token) { SecureRandom.base64(32) }
  let(:redirect_uri) { 'https://me.example.com/auth' }
  let(:state) { SecureRandom.hex(32) }

  let(:populated_session) do
    {
      'csrf' => authenticity_token,
      'me' => 'https://me.example.com/',
      'client_id' => 'https://client_id.example.com/',
      'redirect_uri' => redirect_uri,
      'state' => state,
      'scope' => '',
      'response_type' => 'id'
    }
  end

  before do
    OmniAuth.config.mock_auth[:github] = nil
  end

  context 'when user denies access' do
    before do
      OmniAuth.config.mock_auth[:github] = :access_denied

      post '/auth/github', { authenticity_token: authenticity_token }, 'rack.session' => populated_session

      follow_redirect! # => /auth/github/callback
      follow_redirect! # => /auth/failure
    end

    it 'clears the session' do
      expect(last_request.session.to_h).not_to include(populated_session)
    end

    it 'redirects the user' do
      follow_redirect!

      expect(last_request.url).to eq("#{redirect_uri}?error=access_denied&state=#{state}")
    end
  end

  context 'when unrecognized user' do
    before do
      OmniAuth.config.add_mock(:github, info: { nickname: 'foo' })

      post '/auth/github', { authenticity_token: authenticity_token }, 'rack.session' => populated_session

      follow_redirect! # => /auth/github/callback
    end

    it 'clears the session' do
      expect(last_request.session.to_h).not_to include(populated_session)
    end

    it 'redirects the user' do
      follow_redirect!

      expect(last_request.url).to eq("#{redirect_uri}?error=invalid_request&error_description=The+authentication+provider+returned+an+unrecognized+user&state=#{state}")
    end
  end
end
