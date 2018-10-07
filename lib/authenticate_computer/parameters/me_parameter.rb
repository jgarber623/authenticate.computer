module AuthenticateComputer
  class MeParameter < Parameter
    def valid?
      uri.absolute?
    end

    def self.param
      @param ||= 'me'
    end

    private

    def uri
      @uri ||= Addressable::URI.parse(value)
    end
  end
end
