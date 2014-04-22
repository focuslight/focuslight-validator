module Focuslight
  module Validator
    class Result
      attr_reader :errors

      def initialize
        @errors = {}
        @params = {}
      end

      def hash
        @params.dup
      end

      def [](name)
        @params[name.to_sym]
      end

      def []=(name, value)
        @params[name.to_sym] = value
      end

      def error(param, message)
        @errors[param.to_sym] = "#{param}: " + message
      end

      def has_error?
        not @errors.empty?
      end
    end
  end
end
