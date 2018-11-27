describe AuthenticateComputer::App, 'GET /' do
  context 'when requested without required params' do
    before do
      get '/'
    end

    it 'redirects' do
      expect(last_response.redirect?).to be(true)
    end

    it 'redirects to /hello' do
      follow_redirect!

      expect(last_request.path).to eq('/hello')
    end
  end

  # context 'when requested with invalid required params' do
  # end
  #
  # context 'when requested with valid required params' do
  # end
end
