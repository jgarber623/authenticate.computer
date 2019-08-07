class AuthenticateComputer < Sinatra::Base
  get '/', provides: :html do
    cache_control :public

    erb :'pages/homepage'
  end
end
