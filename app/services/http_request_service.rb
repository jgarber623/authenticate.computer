class HttpRequestService
  # Defaults derived from Webmention specification examples
  # https://www.w3.org/TR/webmention/#limits-on-get-requests
  HTTP_CLIENT_OPTS = {
    follow: {
      max_hops: 20
    },
    headers: {
      accept: '*/*',
      user_agent: 'authenticate.computer HTTP Robot (https://authenticate.computer)'
    },
    timeout_options: {
      connect_timeout: 5,
      read_timeout: 5
    }
  }.freeze

  def initialize
    @client = HTTP::Client.new(HTTP_CLIENT_OPTS)
  end

  def post(url, **options)
    client.request(:post, url, options)
  rescue HTTP::Error
    raise HttpInternalServerError, 'There was a problem fulfilling the request'
  end

  private

  attr_accessor :client
end
