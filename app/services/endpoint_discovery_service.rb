class EndpointDiscoveryService
  def get(url, endpoint)
    IndieWeb::Endpoints.get(url)[endpoint]
  rescue IndieWeb::Endpoints::IndieWebEndpointsError
    raise HttpInternalServerError, 'There was a problem fulfilling the request'
  end
end
