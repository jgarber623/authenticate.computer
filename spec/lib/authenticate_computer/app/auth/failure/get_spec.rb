describe AuthenticateComputer::App, 'when GET /auth/failure' do
  context 'when params[:message] is not present' do
    before do
      get '/auth/failure'

      follow_redirect! # => /
    end

    it 'redirects to the homepage' do
      expect(last_request.path).to eq('/')
      expect(last_response.status).to eq(200)
    end
  end

  context 'when params[:message] is blank' do
    before do
      get '/auth/failure', message: ''

      follow_redirect! # => /
    end

    it 'redirects to the homepage' do
      expect(last_request.path).to eq('/')
      expect(last_response.status).to eq(200)
    end
  end
end
