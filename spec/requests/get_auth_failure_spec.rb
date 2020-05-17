RSpec.describe AuthenticateComputer, 'GET /auth/failure' do
  context 'when session is invalid' do
    it 'renders the 400 view' do
      get '/auth/failure'

      expect(last_response.status).to eq(400)
      expect(last_response.body).to include('An authentication error prevented successful completion of the request')
    end
  end
end
