class ClientMetadata
  # @param response [HTTP::Response]
  def initialize(response)
    @response = response
    @properties = h_app.try(:properties).try(:to_h) || {}
  end

  def logo
    properties[:logo]&.first
  end

  def name
    properties[:name]&.first || response.uri.host
  end

  def summary
    properties[:summary]&.first
  end

  def url
    properties[:url]&.first || response.uri.to_s
  end

  private

  attr_reader :properties, :response

  def doc
    MicroMicro.parse(response.body.to_s, response.uri.to_s)
  end

  def h_app
    doc.items.find { |item| (item.types & ['h-app', 'h-x-app']).any? }
  end
end
