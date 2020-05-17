RSpec.describe AuthenticateComputer, 'when performing an Authentication Request', omniauth: true do
  let(:authenticity_token) { SecureRandom.base64(32) }

  let(:me) { 'https://sixtwothree.org/' }
  let(:client_id) { 'https://indieauth.com/' }
  let(:redirect_uri) { 'https://indieauth.com/success' }
  let(:state) { SecureRandom.hex(8) }
  let(:scope) { '' }
  let(:response_type) { 'id' }

  let(:code) { SecureRandom.hex(32) }

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

    get '/auth', parameters_hash
    post '/auth/github', { authenticity_token: authenticity_token }, 'rack.session' => session_hash

    follow_redirect! # => /auth/github/callback

    header 'Accept', 'application/json'
    post '/auth', code: code, client_id: client_id, redirect_uri: redirect_uri
  end

  it 'returns the response JSON' do
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq({ me: me }.to_json)
  end
end
