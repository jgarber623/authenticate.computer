module AuthenticateComputer
  class AuthenticationRequest
    attr_reader :client_id, :me, :redirect_uri, :response_type, :state

    def initialize(params)
      @me = params.fetch('me', nil)
      # @client_id = params.fetch('client_id', nil)
      # @redirect_uri = params.fetch('redirect_uri', nil)
      # @state = params.fetch('state', nil)
      # @response_type = params.fetch('response_type', 'id')
    end

    def parameter_errors
      @parameter_errors ||= validate_parameters
    end

    def valid?
      parameter_errors.empty?
    end

    private

    def validate_parameters
      errors = []

      # Parameter.subclasses.each do |klass|
      #   parameter = klass.new(send(klass.param))
      #
      #   errors << "Required parameter #{klass.param} is missing." && next unless parameter.present?
      #   errors << "Required parameter #{klass.param} is invalid." unless parameter.valid?
      # end

      errors
    end
  end
end
