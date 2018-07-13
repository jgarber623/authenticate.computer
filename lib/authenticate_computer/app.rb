module AuthenticateComputer
  class App < Sinatra::Base
    set :root, File.dirname(File.expand_path('..', __dir__))
  end
end
