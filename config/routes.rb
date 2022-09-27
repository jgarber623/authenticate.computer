class ActionParameterConstraint
  def matches?(request)
    request.request_parameters.key?('action')
  end
end

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # IndieAuth IndieWeb Living Standard
  # § 5.2 Authorization Request
  # https://indieauth.spec.indieweb.org/#authorization-request
  get 'auth', to: 'authorizations#new'

  # IndieAuth IndieWeb Living Standard
  # 5.3 Redeeming the Authorization Code (profile URL request)
  # https://indieauth.spec.indieweb.org/#x5-3-redeeming-the-authorization-code
  post 'auth', to: 'authorizations#show', format: :json

  # IndieAuth IndieWeb Living Standard
  # 5.3 Redeeming the Authorization Code (access token request)
  # https://indieauth.spec.indieweb.org/#x5-3-redeeming-the-authorization-code
  post 'token', to: 'tokens#create', format: :json, constraints: !ActionParameterConstraint.new

  # IndieAuth IndieWeb Living Standard
  # § 6.1 Access Token Verification Request
  # https://indieauth.spec.indieweb.org/#access-token-verification-request
  get 'token', to: 'tokens#show', format: :json

  # IndieAuth IndieWeb Living Standard
  # § 7.1 Token Revocation Request
  # https://indieauth.spec.indieweb.org/#token-revocation-request
  post 'token', to: 'tokens#destroy', format: :json, constraints: ActionParameterConstraint.new
end
