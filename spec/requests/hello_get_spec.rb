describe AuthenticateComputer::App, 'GET /hello' do
  let(:hello_page_content) { '<h1>Hello, world!</h1>' }

  it 'renders the hello view' do
    get '/hello'

    expect(last_response.body).to include(hello_page_content)
  end
end
