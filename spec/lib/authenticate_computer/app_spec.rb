describe AuthenticateComputer::App do
  xit 'renders the homepage' do
    get '/'

    expect(last_response.status).to eq(200)
  end
end
