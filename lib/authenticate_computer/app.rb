module AuthenticateComputer
  class App < Sinatra::Base
    register Sinatra::AssetPipeline
    register Sinatra::Param
    register Sinatra::Partial
    register Sinatra::RespondWith

    configure do
      set :root, File.dirname(File.expand_path('..', __dir__))

      set :datastore, Redis.new
      set :partial_template_engine, :erb
      set :partial_underscores, true
      set :raise_sinatra_param_exceptions, true

      use Rack::Session::Cookie, expire_after: 60, key: ENV['COOKIE_NAME'], secret: ENV['COOKIE_SECRET']

      use Rack::Protection, use: [:cookie_tossing]
      use Rack::Protection::AuthenticityToken, allow_if: ->(env) { env['PATH_INFO'] == '/auth' && env['REQUEST_METHOD'] == 'POST' }
      # use Rack::Protection::ContentSecurityPolicy
      # use Rack::Protection::StrictTransport, max_age: 31536000, include_subdomains: true, preload: true

      use OmniAuth::Builder do
        provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], scope: 'read:user'
      end

      OmniAuth.config.allowed_request_methods = [:post]
      OmniAuth.config.on_failure = ->(env) { OmniAuth::FailureEndpoint.new(env).redirect_to_failure }
    end

    helpers do
      def normalize_url(url)
        Addressable::URI.parse(url).normalize.to_s
      end

      def render_alert(**locals)
        respond_to do |format|
          format.html { partial :alert, locals: locals }
          format.json { json error: locals[:error], error_description: "#{locals[:error_title]}: #{locals[:error_description]}" }
        end
      end
    end

    after do
      halt [406, { 'Content-Type' => 'text/plain' }, 'The requested format is not supported'] if status == 500 && body.include?('Unknown template engine')
    end

    get '/', provides: :html do
      erb :homepage
    end

    # Authentication Request
    # https://indieauth.spec.indieweb.org/#authentication-request
    get '/auth', provides: :html do
      session[:me]            = param :me,            :string, required: true, format: uri_regexp, transform: ->(url) { normalize_url(url) }
      session[:client_id]     = param :client_id,     :string, required: true, format: uri_regexp, transform: ->(url) { normalize_url(url) }
      session[:redirect_uri]  = param :redirect_uri,  :string, required: true, format: uri_regexp, in: [valid_redirect_uris(params[:client_id], params[:redirect_uri])].flatten.compact, transform: ->(url) { normalize_url(url) }
      session[:state]         = param :state,         :string, required: true, minlength: 16
      session[:scope]         = param :scope,         :array,  default: [], delimiter: /(?:\+|%20)+/
      session[:response_type] = param :response_type, :string, default: 'id', in: %w[code id]

      # TODO: fetch the me URL for user information
      # TODO: fetch the client_id URL for app information

      erb :auth, locals: { csrf_token: env['rack.session'][:csrf], client_id: params[:client_id], me: session[:me], redirect_uri: session[:redirect_uri] }
    rescue Sinatra::Param::InvalidParameterError => exception
      raise HttpBadRequest, exception
    end

    # Authentication Error Response
    # https://tools.ietf.org/html/rfc6749#section-4.1.2.1
    get '/auth/failure', provides: :html do
      raise HttpBadRequest, 'An authentication error prevented successful completion of the request' unless valid_session?

      redirect_uri = "#{session[:redirect_uri]}?#{URI.encode_www_form(error: params[:message], state: session[:state])}"

      session.clear

      redirect redirect_uri
    end

    # Authentication Response
    # https://indieauth.spec.indieweb.org/#authentication-response
    get '/auth/github/callback', provides: :html do
      raise HttpLoginTimeout, 'Session expired during authentication' unless valid_session?

      if valid_user?
        code = SecureRandom.hex(32)

        key = [code, session[:client_id], session[:redirect_uri]].join('_')
        value = session.to_h.slice('me', 'scope', 'response_type').to_json

        settings.datastore.set(key, value, ex: 60)

        redirect_params = { code: code, state: session[:state] }
      else
        redirect_params = { error: 'invalid_request', error_description: 'The authentication provider returned an unrecognized user', state: session[:state] }
      end

      redirect_uri = "#{session[:redirect_uri]}?#{URI.encode_www_form(redirect_params)}"

      session.clear

      redirect redirect_uri
    end

    # Authorization Code Verification
    # https://indieauth.spec.indieweb.org/#authorization-code-verification
    post '/auth', provides: :json do
      code         = param :code,         required: true, format: /^[a-f0-9]{64}$/
      client_id    = param :client_id,    required: true, format: uri_regexp, transform: ->(url) { normalize_url(url) }
      redirect_uri = param :redirect_uri, required: true, format: uri_regexp, transform: ->(url) { normalize_url(url) }

      key = [code, client_id, redirect_uri].join('_')

      raise HttpBadRequest, 'Authorization code verification could not be completed' unless settings.datastore.exists(key)

      value = JSON.parse(settings.datastore.get(key))

      settings.datastore.del(key) if value['response_type'] == 'id'

      json me: value['me']
    rescue Sinatra::Param::InvalidParameterError => exception
      raise HttpBadRequest, exception
    end

    error 400 do
      render_alert error: 'invalid_request', error_title: '400 Bad Request', error_description: "#{request.env['sinatra.error'].message}. Please try again."
    end

    error 404 do
      render_alert error: 'file_not_found', error_title: '404 File Not Found', error_description: %(The requested URL could not be found. Head on <a href="/" rel="home">back to the homepage</a>.)
    end

    error 440 do
      render_alert error: 'session_timeout', error_title: '440 Session Timeout', error_description: "#{request.env['sinatra.error'].message}. Please try again."
    end

    error 500 do
      render_alert error: 'server_error', error_title: '500 Internal Server Error', error_description: "#{request.env['sinatra.error'].message}. Please try again later."
    end

    private

    def uri_regexp
      @uri_regexp ||= %r{^https?://.*}
    end

    def valid_redirect_uris(client_id, redirect_uri)
      return unless client_id && redirect_uri

      return redirect_uri if Addressable::URI.parse(redirect_uri).host == Addressable::URI.parse(client_id).host

      IndieWeb::Endpoints.get(client_id).redirect_uri
    rescue IndieWeb::Endpoints::IndieWebEndpointsError
      raise HttpInternalServerError, 'There was a problem fulfilling the request'
    end

    def valid_session?
      %w[me client_id redirect_uri state scope response_type].all? { |key| session.key?(key) }
    end

    def valid_user?
      request.env['omniauth.auth']['info']['nickname'] == ENV['GITHUB_USER']
    end
  end
end
