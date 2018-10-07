module AuthenticateComputer
  class Parameter
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def present?
      (value && !value.empty?) || false
    end

    class << self
      def inherited(base)
        subclasses << base

        super(base)
      end

      def subclasses
        @subclasses ||= []
      end
    end
  end
end
