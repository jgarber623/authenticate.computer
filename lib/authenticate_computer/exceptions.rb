module AuthenticateComputer
  # rubocop:disable Layout/AlignHash
  HTTP_STATUS_CODES = {
    HttpBadRequest:          400,
    HttpUnauthorized:        401,
    HttpForbidden:           403,
    HttpLoginTimeout:        440,
    HttpInternalServerError: 500
  }.freeze
  # rubocop:enable Layout/AlignHash

  HTTP_STATUS_CODES.each do |status, code|
    klass = Class.new(StandardError) do
      define_method :http_status, -> { code }
    end

    Object.const_set(status, klass)
  end
end
