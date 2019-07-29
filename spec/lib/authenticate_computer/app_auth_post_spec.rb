describe AuthenticateComputer::App do
  context 'when POST /auth' do
    let(:code) { SecureRandom.hex(32) }
    let(:client_id) { 'https://client_id.example.com' }
    let(:redirect_uri) { 'https://me.example.com/auth' }

    let(:error) { '400 Bad Request' }

    before do
      header 'Accept', 'application/json'
    end

    context 'when params[:code] is not present' do
      it 'renders the 400 JSON' do
        post '/auth'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq({ error: error, message: 'Parameter code is required and cannot be blank. Please correct this error and try again.' }.to_json)
      end
    end

    context 'when params[:code] is invalid' do
      it 'renders the 400 JSON' do
        post '/auth', code: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq({ error: error, message: 'Parameter code value "foo" must match format ^[a-f0-9]{64}$. Please correct this error and try again.' }.to_json)
      end
    end

    context 'when params[:client_id] is not present' do
      it 'renders the 400 JSON' do
        post '/auth', code: code

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq({ error: error, message: 'Parameter client_id is required and cannot be blank. Please correct this error and try again.' }.to_json)
      end
    end

    context 'when params[:client_id] is invalid' do
      it 'renders the 400 JSON' do
        post '/auth', code: code, client_id: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq({ error: error, message: 'Parameter client_id value "foo" must match format ^https?://.*. Please correct this error and try again.' }.to_json)
      end
    end

    context 'when params[:redirect_uri] is not present' do
      it 'renders the 400 JSON' do
        post '/auth', code: code, client_id: client_id

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq({ error: error, message: 'Parameter redirect_uri is required and cannot be blank. Please correct this error and try again.' }.to_json)
      end
    end

    context 'when params[:redirect_uri] is invalid' do
      it 'renders the 400 JSON' do
        post '/auth', code: code, client_id: client_id, redirect_uri: 'foo'

        expect(last_response.status).to eq(400)
        expect(last_response.body).to eq({ error: error, message: 'Parameter redirect_uri value "foo" must match format ^https?://.*. Please correct this error and try again.' }.to_json)
      end
    end

    context 'when authorization code verification request is invalid'

    context 'when authorization code verification request is valid' do
      xit 'renders the response JSON' do
        post '/auth', code: code, client_id: client_id, redirect_uri: redirect_uri

        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq({ me: 'https://me.example.com/' }.to_json)
      end
    end
  end
end
