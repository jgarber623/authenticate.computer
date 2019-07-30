describe AuthenticateComputer::App do
  context 'when GET /' do
    before do
      header 'Accept', 'text/plain'
    end

    it 'renders the 406 message' do
      get '/'

      expect(last_response.status).to eq(406)
      expect(last_response.body).to eq('The requested format is not supported')
    end
  end
end
