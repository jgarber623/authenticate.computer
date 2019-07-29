describe AuthenticateComputer::App do
  context 'when POST /auth/github' do
    let(:authenticity_token) { SecureRandom.base64(32) }
    let(:redirect_uri) { 'https://me.example.com/auth' }

    let(:populated_session) do
      {
        'csrf' => authenticity_token,
        'redirect_uri' => redirect_uri
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

        expect(last_request.url).to eq("#{redirect_uri}?error=access_denied")
      end
    end

    context 'when unrecognized user' do
      before do
        OmniAuth.config.add_mock(:github, info: { nickname: 'foo' })
      end

      it 'renders the 403 view' do
        post '/auth/github', { authenticity_token: authenticity_token }, 'rack.session' => populated_session

        follow_redirect! # => /auth/github/callback

        expect(last_response.status).to eq(403)
        expect(last_response.body).to include('Authentication provider returned an unrecognized user')
      end
    end
  end
end
