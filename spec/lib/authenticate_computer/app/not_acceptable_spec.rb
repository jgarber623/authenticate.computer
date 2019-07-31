describe AuthenticateComputer::App, 'when GET /foo' do
  it 'renders the 406 message' do
    header 'Accept', 'text/plain'
    get '/foo'

    expect(last_response.status).to eq(406)
    expect(last_response.body).to eq('The requested format is not supported')
  end
end
