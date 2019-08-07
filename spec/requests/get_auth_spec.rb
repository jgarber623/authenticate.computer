describe AuthenticationsController, 'GET /auth' do
  let(:me) { 'https://me.example.com/' }
  let(:client_id) { 'https://client_id.example.com/' }
  let(:redirect_uri) { 'https://me.example.com/auth' }
  let(:state) { SecureRandom.hex(32) }
  let(:scope) { 'create+update+delete' }

  before do
    stub_request(:get, client_id).to_return(headers: { 'Content-Type': 'text/html', 'Link': %(<#{redirect_uri}>; rel="redirect_uri") })
  end

  context 'when validating params' do
    context 'when params[:me] is not present' do
      it 'renders the 400 view' do
        get '/auth'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to include('Parameter me is required and cannot be blank')
      end
    end

    context 'when params[:me] is invalid' do
      it 'renders the 400 view' do
        get '/auth', me: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to include('Parameter me value "foo" must match format ^https?://.*')
      end
    end

    context 'when params[:client_id] is not present' do
      it 'renders the 400 view' do
        get '/auth', me: me

        expect(last_response.status).to eq(400)
        expect(last_response.body).to include('Parameter client_id is required and cannot be blank')
      end
    end

    context 'when params[:client_id] is invalid' do
      it 'renders the 400 view' do
        get '/auth', me: me, client_id: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to include('Parameter client_id value "foo" must match format ^https?://.*')
      end
    end

    context 'when params[:client_id] is unreachable' do
      before do
        stub_request(:get, client_id).to_timeout
      end

      it 'renders the 500 view' do
        get '/auth', me: me, client_id: client_id, redirect_uri: redirect_uri

        expect(last_response.status).to eq(500)
        expect(last_response.body).to include('There was a problem fulfilling the request')
      end
    end

    context 'when params[:redirect_uri] is not present' do
      it 'renders the 400 view' do
        get '/auth', me: me, client_id: client_id

        expect(last_response.status).to eq(400)
        expect(last_response.body).to include('Parameter redirect_uri is required and cannot be blank')
      end
    end

    context 'when params[:redirect_uri] is invalid' do
      it 'renders the 400 view' do
        get '/auth', me: me, client_id: client_id, redirect_uri: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to include('Parameter redirect_uri value "foo" must match format ^https?://.*')
      end
    end

    context 'when params[:redirect_uri] is not in permitted values' do
      it 'renders the 400 view' do
        get '/auth', me: me, client_id: client_id, redirect_uri: 'https://foo.example.com/auth'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to include(%(Parameter redirect_uri value "https://foo.example.com/auth" must be in [#{redirect_uri}]))
      end
    end

    context 'when params[:state] is not present' do
      it 'renders the 400 view' do
        get '/auth', me: me, client_id: client_id, redirect_uri: redirect_uri

        expect(last_response.status).to eq(400)
        expect(last_response.body).to include('Parameter state is required and cannot be blank')
      end
    end

    context 'when params[:state] is invalid' do
      it 'renders the 400 view' do
        get '/auth', me: me, client_id: client_id, redirect_uri: redirect_uri, state: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to include('Parameter state value "foo" length must be at least 16')
      end
    end

    context 'when params[:response_type] is not in permitted values' do
      it 'renders the 400 view' do
        get '/auth', me: me, client_id: client_id, redirect_uri: redirect_uri, state: state, response_type: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to include('Parameter response_type value "foo" must be in [code, id]')
      end
    end
  end

  context 'when authentication request is valid' do
    let(:session_hash) do
      {
        'indieauth.me' => me,
        'indieauth.client_id' => client_id,
        'indieauth.redirect_uri' => redirect_uri,
        'indieauth.state' => state,
        'indieauth.scope' => [],
        'indieauth.response_type' => 'id'
      }
    end

    before do
      get '/auth', me: me, client_id: client_id, redirect_uri: redirect_uri, state: state
    end

    it 'populates the session' do
      expect(last_request.session.to_h).to include(session_hash)
    end

    it 'renders the auth view' do
      expect(last_response.body).to include('Sign in to <b>client_id.example.com</b>')
    end
  end

  context 'when authorization request is valid' do
    let(:session_hash) do
      {
        'indieauth.me' => me,
        'indieauth.client_id' => client_id,
        'indieauth.redirect_uri' => redirect_uri,
        'indieauth.state' => state,
        'indieauth.scope' => scope.split('+'),
        'indieauth.response_type' => 'code'
      }
    end

    before do
      get '/auth', me: me, client_id: client_id, redirect_uri: redirect_uri, state: state, scope: scope, response_type: 'code'
    end

    it 'populates the session' do
      expect(last_request.session.to_h).to include(session_hash)
    end

    it 'renders the auth view' do
      expect(last_response.body).to include('Allow access to <b>me.example.com</b>?')
    end
  end
end
