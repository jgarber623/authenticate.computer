module AuthenticateComputer
  class HttpBadRequest < StandardError
    def http_status
      400
    end
  end

  class HttpUnauthorized < StandardError
    def http_status
      401
    end
  end

  class HttpForbidden < StandardError
    def http_status
      403
    end
  end

  class HttpLoginTimeout < StandardError
    def http_status
      440
    end
  end

  class HttpInternalServerError < StandardError
    def http_status
      500
    end
  end
end
