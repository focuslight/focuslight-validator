module Focuslight
  module Validator
    class Rule
      attr_reader :message

      def initialize(checker, invalid_message, formatter=nil)
        @checker = checker
        @message = invalid_message
        @formatter = formatter
      end

      def check(*values)
        @checker.(*values)
      end

      def format(value)
        if @formatter && @formatter.is_a?(Symbol)
          value.send(@formatter)
        elsif @formatter
          @formatter.(value)
        else
          value
        end
      end
    end
  end
end
