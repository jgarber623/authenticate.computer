module AuthenticateComputer
  class App < Sinatra::Base
    set :root, File.dirname(File.expand_path('..', __dir__))

    get '/' do
      redirect '/hello' if params.empty?

      # authentication_request = AuthenticationRequest.new(params)

      # erb :index, locals: { errors: authentication_request.parameter_errors } unless authentication_request.valid?
    end

    get '/hello' do
      erb :hello
    end
  end
end
