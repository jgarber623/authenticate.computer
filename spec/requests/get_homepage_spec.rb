describe AuthenticateComputer, 'GET /' do
  it 'renders the homepage view' do
    get '/'

    expect(last_response.status).to eq(200)
  end
end
