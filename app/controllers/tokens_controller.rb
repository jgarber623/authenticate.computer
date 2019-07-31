class TokensController < ApplicationController
  namespace '/token' do
    # Token Request
    # https://indieauth.spec.indieweb.org/#token-request
    post provides: :json do
      param :grant_type,   required: true, match: 'authorization_code'
      param :code,         required: true, format: code_regexp
      param :client_id,    required: true, format: uri_regexp
      param :redirect_uri, required: true, format: uri_regexp
      param :me,           required: true, format: uri_regexp

      authorization_endpoint = IndieWeb::Endpoints.get(params[:me]).authorization_endpoint
      verification_response = HTTP.headers(accept: 'application/json').post(authorization_endpoint, form: params.slice(:code, :client_id, :redirect_uri))

      raise HttpBadRequest, 'Authorization code verification could not be completed' unless verification_response.status.success?

      verification_json = JSON.parse(verification_response.body, symbolize_names: true)

      raise HttpBadRequest, %(The requested scope is invalid) if verification_json[:scope].blank?

      token = SecureRandom.hex(64)
      value = { me: verification_json[:me], client_id: params[:client_id], scope: verification_json[:scope] }.to_json

      # Expire token after 30 days
      settings.datastore.set(token, value, ex: 2_592_000)

      json access_token: token, token_type: 'Bearer', scope: verification_json[:scope], me: verification_json[:me]
    rescue HTTP::Error, IndieWeb::Endpoints::IndieWebEndpointsError
      raise HttpInternalServerError, 'There was a problem fulfilling the request'
    rescue Sinatra::Param::InvalidParameterError => exception
      raise HttpBadRequest, exception
    end

    # Access Token Verification
    # https://indieauth.spec.indieweb.org/#access-token-verification
    get provides: :json do
      token = request.env['HTTP_AUTHORIZATION']

      raise HttpBadRequest, 'The request is missing a valid HTTP Authorization header' unless token.present? && token.sub!(/^Bearer\s/, '')
      raise HttpBadRequest, 'Access token verification could not be completed' unless settings.datastore.exists(token)

      settings.datastore.expire(token, 2_592_000)

      settings.datastore.get(token)
    end
  end
end
