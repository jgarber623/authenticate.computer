describe AuthenticateComputer::App do
  let(:message) { '404 File Not Found' }

  context 'when GET /foo' do
    it 'renders the 404 view' do
      get '/foo'

      expect(last_response.status).to eq(404)
      expect(last_response.body).to include(message)
    end
  end
end
