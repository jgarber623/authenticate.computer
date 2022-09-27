class ClientMetadataService < ApplicationService
  def fetch_client_metadata(url)
    ClientMetadata.new(HTTP.get(url))
  rescue HTTP::Error => e
    # log some stuff
    # fail gracefully
  end
end
