describe AuthenticateComputer::App, 'when GET /auth/failure' do
  context 'when params[:message] is not present' do
    it 'redirects to the homepage' do
      get '/auth/failure'

      follow_redirect! # => /

      expect(last_request.path).to eq('/')
      expect(last_response.status).to eq(200)
    end
  end

  context 'when params[:message] is blank' do
    it 'redirects to the homepage' do
      get '/auth/failure', message: ''

      follow_redirect! # => /

      expect(last_request.path).to eq('/')
      expect(last_response.status).to eq(200)
    end
  end
end
