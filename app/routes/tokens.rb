class AuthenticateComputer < Sinatra::Base
  # Token Request
  # https://indieauth.spec.indieweb.org/#token-request
  post '/token', provides: :json do
    param :grant_type,   required: true, match: 'authorization_code'
    param :code,         required: true, format: code_regexp
    param :client_id,    required: true, format: uri_regexp
    param :redirect_uri, required: true, format: uri_regexp
    param :me,           required: true, format: uri_regexp

    authorization_endpoint = EndpointDiscoveryService.new.get(params[:me], :authorization_endpoint)
    verification_response = HttpRequestService.new.post(authorization_endpoint, form: params.slice(:code, :client_id, :redirect_uri), headers: { accept: 'application/json' })

    raise HttpBadRequest, 'Authorization code verification could not be completed' unless verification_response.status.success?

    data = JSON.parse(verification_response.body, symbolize_names: true)

    raise HttpBadRequest, %(The requested scope is invalid) if data[:scope].blank?

    token = SecureRandom.hex(64)
    value = { me: data[:me], client_id: params[:client_id], scope: data[:scope] }.to_json

    # Expire token after 30 days
    settings.datastore.set(token, value, ex: 2_592_000)

    json access_token: token, token_type: 'Bearer', scope: data[:scope], me: data[:me]
  rescue Sinatra::Param::InvalidParameterError => exception
    raise HttpBadRequest, exception
  end

  # Access Token Verification
  # https://indieauth.spec.indieweb.org/#access-token-verification
  get '/token', provides: :json do
    token = request.env['HTTP_AUTHORIZATION']

    raise HttpBadRequest, 'The request is missing a valid HTTP Authorization header' unless token.present? && token.sub!(/^Bearer\s/, '')
    raise HttpBadRequest, 'Access token verification could not be completed' unless settings.datastore.exists(token)

    # Expire token after 30 days
    settings.datastore.expire(token, 2_592_000)

    settings.datastore.get(token)
  end
end
