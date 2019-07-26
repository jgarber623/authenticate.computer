describe AuthenticateComputer::App do
  context 'when POST /auth/github' do
    let(:authenticity_token) { SecureRandom.base64(32) }

    let(:populated_session) do
      {
        csrf: authenticity_token
      }
    end

    before do
      OmniAuth.config.mock_auth[:github] = nil
    end

    context 'when user denies access' do
      before do
        OmniAuth.config.mock_auth[:github] = :access_denied
      end

      it 'renders the auth_failure view' do
        post '/auth/github', { authenticity_token: authenticity_token }, 'rack.session' => populated_session

        follow_redirect! # => /auth/github/callback
        follow_redirect! # => /auth/failure

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('The authentication provider returned the following error: access_denied')
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
