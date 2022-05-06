# frozen_string_literal: true

module MrLogaLoga
  # A structured log message containing the actual message and context
  #
  # @private
  LogMessage = Struct.new(:msg, :context) do
    # Format the log message. This is a fallback for logger exctending MrLogaLoga who do not know how to format
    # LogMessage themselves.
    def inspect
      # This is identical to ActiveRecord::SimpleFormatter
      "#{msg.is_a?(String) ? msg : msg.inspect}\n"
    end
  end
end
