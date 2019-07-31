describe AuthenticateComputer::App, 'when GET /foo' do
  it 'renders the 404 view' do
    header 'Accept', 'text/html'
    get '/foo'

    expect(last_response.status).to eq(404)
    expect(last_response.body).to include('The requested URL could not be found')
  end
end
