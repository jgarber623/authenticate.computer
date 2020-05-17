RSpec.describe AuthenticateComputer, 'GET /foo' do
  context 'when requesting text/html' do
    it 'renders the 404 view' do
      header 'Accept', 'text/html'
      get '/foo'

      expect(last_response.status).to eq(404)
      expect(last_response.body).to include('The requested URL could not be found')
    end
  end

  context 'when requesting text/plain' do
    it 'renders the 406 message' do
      header 'Accept', 'text/plain'
      get '/foo'

      expect(last_response.status).to eq(406)
      expect(last_response.body).to eq('The requested format is not supported')
    end
  end
end
