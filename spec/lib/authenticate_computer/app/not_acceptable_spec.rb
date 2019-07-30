describe AuthenticateComputer::App, 'when GET /foo' do
  before do
    header 'Accept', 'text/plain'

    get '/foo'
  end

  it 'renders the 406 message' do
    expect(last_response.status).to eq(406)
    expect(last_response.body).to eq('The requested format is not supported')
  end
end
