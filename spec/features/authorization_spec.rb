describe ApplicationController, 'when performing an Authorization Request', omniauth: true, redis: true do
  let(:authenticity_token) { SecureRandom.base64(32) }

  let(:me) { 'https://me.example.com/' }
  let(:client_id) { 'https://client_id.example.com/' }
  let(:redirect_uri) { 'https://indieauth.com/success' }
  let(:state) { SecureRandom.hex(8) }
  let(:scope) { 'create+update+delete' }
  let(:response_type) { 'code' }

  let(:code) { SecureRandom.hex(32) }
  let(:token) { SecureRandom.hex(64) }

  let(:authorization_endpoint) { 'https://auth.example.com/auth' }

  let(:parameters_hash) do
    {
      me: me,
      client_id: client_id,
      redirect_uri: redirect_uri,
      state: state,
      scope: scope,
      response_type: response_type
    }
  end

  let(:session_hash) do
    {
      'csrf' => authenticity_token,
      'me' => me,
      'client_id' => client_id,
      'redirect_uri' => redirect_uri,
      'state' => state,
      'scope' => scope.split('+'),
      'response_type' => response_type
    }
  end

  before do
    OmniAuth.config.add_mock(:github, info: { nickname: ENV['GITHUB_USER'] })

    allow(SecureRandom).to receive(:hex).and_return(code)

    stub_request(:get, me).to_return(headers: { 'Content-Type': 'text/html', 'Link': %(<#{authorization_endpoint}>; rel="authorization_endpoint") })
    stub_request(:post, authorization_endpoint).to_return(body: { me: me, scope: scope }.to_json)

    get '/auth', parameters_hash
    post '/auth/github', { authenticity_token: authenticity_token }, 'rack.session' => session_hash

    follow_redirect! # => /auth/github/callback

    header 'Accept', 'application/json'
    post '/token', grant_type: 'authorization_code', code: code, client_id: client_id, redirect_uri: redirect_uri, me: me

    header 'Accept', 'application/json'
    header 'Authorization', "Bearer #{token}"
    get '/token'
  end

  it 'returns the response JSON' do
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({ me: me, client_id: client_id, scope: scope }.to_json)
  end
end
