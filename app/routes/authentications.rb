class AuthenticateComputer < Sinatra::Base
  # Authentication Request
  # https://indieauth.spec.indieweb.org/#authentication-request
  get '/auth', provides: :html do
    session[:me]            = param :me,            :string, required: true, format: uri_regexp, transform: ->(url) { normalize_url(url) }
    session[:client_id]     = param :client_id,     :string, required: true, format: uri_regexp, transform: ->(url) { normalize_url(url) }
    session[:redirect_uri]  = param :redirect_uri,  :string, required: true, format: uri_regexp, in: redirect_uris_from(params[:client_id], params[:redirect_uri]), transform: ->(url) { normalize_url(url) }
    session[:state]         = param :state,         :string, required: true, minlength: 16
    session[:scope]         = param :scope,         :array,  default: [], delimiter: /(?:\s|%20|\+|,)+/
    session[:response_type] = param :response_type, :string, default: 'id', in: %w[code id]

    # TODO: fetch the me URL for user information
    # TODO: fetch the client_id URL for app information

    erb :'authentications/index', locals: session.to_h.slice('csrf', 'me', 'client_id', 'redirect_uri', 'scope', 'response_type')
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
    code         = param :code,         required: true, format: code_regexp
    client_id    = param :client_id,    required: true, format: uri_regexp
    redirect_uri = param :redirect_uri, required: true, format: uri_regexp

    key = [code, client_id, redirect_uri].join('_')

    raise HttpBadRequest, 'Authorization code verification could not be completed' unless settings.datastore.exists(key)

    value = JSON.parse(settings.datastore.get(key), symbolize_names: true)

    settings.datastore.del(key) if value[:response_type] == 'id'

    data = { me: value[:me] }
    data.merge!(scope: value[:scope]) if value[:response_type] == 'code'

    json data
  rescue Sinatra::Param::InvalidParameterError => exception
    raise HttpBadRequest, exception
  end

  private

  def redirect_uris_from(client_id, redirect_uri)
    return [] unless client_id && redirect_uri

    return [redirect_uri] if host_from(redirect_uri) == host_from(client_id)

    EndpointDiscoveryService.new.get(client_id, :redirect_uri).to_a
  end

  def valid_session?
    %w[me client_id redirect_uri state scope response_type].all? { |key| session.key?(key) }
  end

  def valid_user?
    request.env['omniauth.auth']['info']['nickname'] == ENV['GITHUB_USER']
  end
end
