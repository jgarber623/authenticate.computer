module AuthenticateComputer
  class App < Sinatra::Base
    set :root, File.dirname(File.expand_path('..', __dir__))
    set :server, :puma

    use Rack::Session::Cookie, expire_after: 60, key: '_authenticate_computer_session', secret: (ENV['COOKIE_SECRET'] || SecureRandom.hex(32))

    REDIS = Redis.new

    get '/auth' do
      # validate these parameters exist and/or match format
      # validate that the redirect_uri is allowed
      # fetch client details and show them in view
      # display notice about scopes (if any) and note to user about proceeding grants access
      session[:me] = params[:me]
      session[:client_id] = params[:client_id]
      session[:redirect_uri] = params[:redirect_uri]
      session[:scope] = params.fetch(:scope, '')
      session[:state] = params[:state]

      # This view should do something to auth a user for real
      # instead of posting to `/login`
      erb :auth
    end

    get '/auth/callback' do
      # confirm auth details are accurate (how?)
      # check that session is in good shape, if not throw an error
      # generate code
      # store key/code combo in REDIS
      # build redirect URL
      # clear the session
      # redirect to redirect URL
    end

    post '/login' do
      code = SecureRandom.hex(32)

      key = [code, session[:redirect_uri], session[:client_id]].join('_')
      data = { me: session[:me], scope: session[:scope] }

      REDIS.set(key, data.to_json)
      REDIS.expire(key, 60)

      url = "#{session[:redirect_uri]}?#{URI.encode_www_form(code: code, me: session[:me], state: session[:state])}"

      session.clear

      redirect url
    end

    post '/auth' do
      content_type :json

      key = [params[:code], params[:redirect_uri], params[:client_id]].join('_')

      data = REDIS.get(key)

      { me: JSON.parse(data) }.to_json
    end

    # set :datastore, Redis.new
    #
    # enable :logging
    #
    # get '/auth' do
    #   # Validate parameters first
    #
    #   session[:me] = params[:me]
    #   session[:client_id] = params[:client_id]
    #   session[:redirect_uri] = params[:redirect_uri]
    #   session[:state] = params[:state]
    #
    #   # Authenticate the user before responding or redirecting
    #
    #   code = SecureRandom.hex(32)
    #   key = [code, session[:client_id], session[:redirect_uri]].join('_')
    #
    #   settings.datastore.set(key, { me: session[:me] }.to_json)
    #   settings.datastore.expire(key, 60)
    #
    #   # response_uri = "#{session[:redirect_uri]}?#{URI.encode_www_form(code: code, state: session[:state])}"
    #
    #   logger.info("curl http://localhost:9393/auth -d 'code=#{code}&client_id=#{session[:client_id]}&redirect_uri=#{session[:redirect_uri]}'")
    #
    #   session.clear
    #
    #
    #   # logger.info(key)
    #   # logger.info(settings.datastore.get(key))
    #
    #   # redirect response_uri
    # end
    #
    # # provides: ['json', 'x-www-form-urlencoded']
    #
    # post '/auth' do
    #   # Validate parameters first
    #   # Verify that code was issued for client_id and redirect_uri combo
    #
    #   key = [params[:code], params[:client_id], params[:redirect_uri]].join('_')
    #
    #   logger.info(settings.datastore.get(key))
    #
    #   # Respond with canonical me value from Redis
    # end
  end
end
