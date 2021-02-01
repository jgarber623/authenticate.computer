RSpec.describe AuthenticateComputer, 'POST /token', redis: true do
  let(:grant_type) { 'authorization_code' }
  let(:code) { SecureRandom.hex(32) }
  let(:client_id) { 'https://client_id.example.com/' }
  let(:redirect_uri) { 'https://me.example.com/auth' }
  let(:me) { 'https://me.example.com/' }

  let(:error) { 'invalid_request' }

  let(:error_hash) do
    {
      error: error,
      error_description: error_description
    }
  end

  before do
    header 'Accept', 'application/json'
  end

  context 'when validating params' do
    context 'when params[:grant_type] is not present' do
      let(:error_description) { '400 Bad Request: Parameter grant_type is required and cannot be blank. Please try again.' }

      it 'renders the 400 JSON' do
        post '/token'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when params[:grant_type] is not valid' do
      let(:error_description) { '400 Bad Request: Parameter grant_type value "foo" must match authorization_code. Please try again.' }

      it 'renders the 400 JSON' do
        post '/token', grant_type: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when params[:code] is not present' do
      let(:error_description) { '400 Bad Request: Parameter code is required and cannot be blank. Please try again.' }

      it 'renders the 400 JSON' do
        post '/token', grant_type: grant_type

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when params[:code] is invalid' do
      let(:error_description) { '400 Bad Request: Parameter code value "foo" must match format ^[a-f0-9]{64}$. Please try again.' }

      it 'renders the 400 JSON' do
        post '/token', grant_type: grant_type, code: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when params[:client_id] is not present' do
      let(:error_description) { '400 Bad Request: Parameter client_id is required and cannot be blank. Please try again.' }

      it 'renders the 400 JSON' do
        post '/token', grant_type: grant_type, code: code

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when params[:client_id] is invalid' do
      let(:error_description) { '400 Bad Request: Parameter client_id value "foo" must match format ^https?://.*. Please try again.' }

      it 'renders the 400 JSON' do
        post '/token', grant_type: grant_type, code: code, client_id: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when params[:redirect_uri] is not present' do
      let(:error_description) { '400 Bad Request: Parameter redirect_uri is required and cannot be blank. Please try again.' }

      it 'renders the 400 JSON' do
        post '/token', grant_type: grant_type, code: code, client_id: client_id

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when params[:redirect_uri] is invalid' do
      let(:error_description) { '400 Bad Request: Parameter redirect_uri value "foo" must match format ^https?://.*. Please try again.' }

      it 'renders the 400 JSON' do
        post '/token', grant_type: grant_type, code: code, client_id: client_id, redirect_uri: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when params[:me] is not present' do
      let(:error_description) { '400 Bad Request: Parameter me is required and cannot be blank. Please try again.' }

      it 'renders the 400 JSON' do
        post '/token', grant_type: grant_type, code: code, client_id: client_id, redirect_uri: redirect_uri

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when params[:me] is invalid' do
      let(:error_description) { '400 Bad Request: Parameter me value "foo" must match format ^https?://.*. Please try again.' }

      it 'renders the 400 JSON' do
        post '/token', grant_type: grant_type, code: code, client_id: client_id, redirect_uri: redirect_uri, me: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end
  end

  context 'when verifying authorization code' do
    let(:authorization_endpoint) { 'https://auth.example.com/auth' }

    let(:populated_parameters) do
      {
        grant_type: grant_type,
        code: code,
        client_id: client_id,
        redirect_uri: redirect_uri,
        me: me
      }
    end

    context 'when authorization endpoint discovery request fails' do
      let(:error) { 'server_error' }
      let(:error_description) { '500 Internal Server Error: There was a problem fulfilling the request. Please try again later.' }

      before do
        stub_request(:get, me).to_timeout
      end

      it 'renders the 500 JSON' do
        post '/token', populated_parameters

        expect(last_response.status).to eq(500)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when authorization code verification request fails' do
      let(:error) { 'server_error' }
      let(:error_description) { '500 Internal Server Error: There was a problem fulfilling the request. Please try again later.' }

      before do
        stub_request(:get, me).to_return(headers: { 'Content-Type': 'text/html', Link: %(<#{authorization_endpoint}>; rel="authorization_endpoint") })
        stub_request(:post, authorization_endpoint).to_timeout
      end

      it 'renders the 500 JSON' do
        post '/token', populated_parameters

        expect(last_response.status).to eq(500)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when authorization code is not verified' do
      let(:error) { 'invalid_request' }
      let(:error_description) { '400 Bad Request: Authorization code verification could not be completed. Please try again.' }

      before do
        stub_request(:get, me).to_return(headers: { 'Content-Type': 'text/html', Link: %(<#{authorization_endpoint}>; rel="authorization_endpoint") })
        stub_request(:post, authorization_endpoint).to_return(body: error_hash.to_json, status: 400)
      end

      it 'renders the 400 JSON' do
        post '/token', populated_parameters

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when scope is not present' do
      let(:error) { 'invalid_request' }
      let(:error_description) { '400 Bad Request: The requested scope is invalid. Please try again.' }

      before do
        stub_request(:get, me).to_return(headers: { 'Content-Type': 'text/html', Link: %(<#{authorization_endpoint}>; rel="authorization_endpoint") })
        stub_request(:post, authorization_endpoint).to_return(body: { me: me, scope: '' }.to_json)
      end

      it 'renders the 400 JSON' do
        post '/token', populated_parameters

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq(error_hash.to_json)
      end
    end

    context 'when scope is valid' do
      before do
        stub_request(:get, me).to_return(headers: { 'Content-Type': 'text/html', Link: %(<#{authorization_endpoint}>; rel="authorization_endpoint") })
        stub_request(:post, authorization_endpoint).to_return(body: { me: me, scope: 'create update delete' }.to_json)

        allow(SecureRandom).to receive(:hex).and_return(code)
      end

      it 'returns the response JSON' do
        post '/token', populated_parameters

        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq({ access_token: code, token_type: 'Bearer', scope: 'create update delete', me: me }.to_json)
      end
    end
  end
end
