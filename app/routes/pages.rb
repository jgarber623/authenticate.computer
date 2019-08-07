class AuthenticateComputer < Sinatra::Base
  get '/', provides: :html do
    erb :'pages/homepage'
  end
end
