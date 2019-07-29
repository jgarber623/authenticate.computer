module AuthenticateComputer
  class App < Sinatra::Base
    register Sinatra::AssetPipeline
    register Sinatra::Param
    register Sinatra::Partial
    register Sinatra::RespondWith

    configure do
      set :root, File.dirname(File.expand_path('..', __dir__))

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
    end

    helpers do
      def normalize_url(url)
        Addressable::URI.parse(url).normalize.to_s
      end

      def render_alert(**locals)
        respond_to do |format|
          format.html { partial :alert, locals: locals }
          format.json { json locals }
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
      session[:me]            = param :me,            required: true, format: uri_regexp, transform: ->(url) { normalize_url(url) }
      session[:client_id]     = param :client_id,     required: true, format: uri_regexp, transform: ->(url) { normalize_url(url) }
      session[:redirect_uri]  = param :redirect_uri,  required: true, format: uri_regexp, in: [valid_redirect_uris(params[:client_id], params[:redirect_uri])].flatten.compact, transform: ->(url) { normalize_url(url) }
      session[:state]         = param :state,         required: true, minlength: 16
      session[:scope]         = param :scope,         default: ''
      session[:response_type] = param :response_type, default: 'id', in: %w[code id]

      # TODO: fetch the me URL for user information
      # TODO: fetch the client_id URL for app information

      erb :auth
    rescue Sinatra::Param::InvalidParameterError => exception
      raise HttpBadRequest, exception
    end

    # Authentication Error Response
    # https://tools.ietf.org/html/rfc6749#section-4.1.2.1
    get '/auth/failure', provides: :html do
      redirect '/' unless valid_session? && params[:message].present?

      redirect_uri = "#{session[:redirect_uri]}?#{URI.encode_www_form(error: params[:message], state: session[:state])}"

      session.clear

      redirect redirect_uri
    end

    # Authentication Response
    # https://indieauth.spec.indieweb.org/#authentication-response
    get '/auth/github/callback', provides: :html do
      raise HttpForbidden, 'Authentication provider returned an unrecognized user' unless valid_user?
      raise HttpLoginTimeout, 'Session expired during authentication' unless valid_session?

      code = SecureRandom.hex(32)

      # TODO: store data in Redis

      redirect_uri = "#{session[:redirect_uri]}?#{URI.encode_www_form(code: code, state: session[:state])}"

      session.clear

      redirect redirect_uri
    end

    # Authorization Code Verification
    # https://indieauth.spec.indieweb.org/#authorization-code-verification
    post '/auth', provides: :json do
      param :code,         required: true, format: /^[a-f0-9]{64}$/
      param :client_id,    required: true, format: uri_regexp, transform: ->(url) { normalize_url(url) }
      param :redirect_uri, required: true, format: uri_regexp, transform: ->(url) { normalize_url(url) }

      # TODO: look for data in Redis
      # TODO: return JSON { me: <url> }
    rescue Sinatra::Param::InvalidParameterError => exception
      raise HttpBadRequest, exception
    end

    error 400 do
      render_alert error: '400 Bad Request', message: "#{request.env['sinatra.error'].message}. Please correct this error and try again."
    end

    error 401 do
      render_alert error: '401 Unauthorized', message: "#{request.env['sinatra.error'].message}."
    end

    error 403 do
      render_alert error: '403 Forbidden', message: "#{request.env['sinatra.error'].message}."
    end

    error 404 do
      render_alert error: '404 File Not Found', message: %(The requested URL could not be found. Head on <a href="/" rel="home">back to the homepage</a>.)
    end

    error 440 do
      render_alert error: '440 Session Timeout', message: "#{request.env['sinatra.error'].message}. Please try again."
    end

    error 500 do
      render_alert error: '500 Internal Server Error', message: "#{request.env['sinatra.error'].message}. Please try again later."
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
