class AuthorizationCodeVerification
  def initialize(options)
    @client_id = options[:client_id]
    @code = options[:code]
    @me = options[:me]
    @redirect_uri = options[:redirect_uri]
  end

  def success?
    http_response.status.success?
  end

  def to_json(*_args)
    JSON.parse(http_response.body, symbolize_names: true)
  end

  private

  attr_accessor :client_id, :code, :me, :redirect_uri

  def authorization_endpoint
    @authorization_endpoint ||= EndpointDiscoveryService.new.get(me, :authorization_endpoint)
  end

  def http_response
    @http_response ||= HttpRequestService.new.post(authorization_endpoint, form: http_request_params, headers: { accept: 'application/json' })
  end

  def http_request_params
    @http_request_params ||= { code: code, client_id: client_id, redirect_uri: redirect_uri }
  end
end
