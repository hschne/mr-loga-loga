# frozen_string_literal: true

module MrLogaLoga
  module Formatters
    # == Description
    #
    # A simple key value formatter that extends the standard formatter by rendering additional contextual information.
    #
    # == Format
    #
    # The key-value formatter renders messages into the following format:
    #
    # Log format:
    #
    #   SeverityID, [DateTime #pid] SeverityLabel -- ProgName: message key1=value1 key2=value2
    #
    class KeyValue < Logger::Formatter
      # Render a log message
      #
      # @param severity [String] The message severity
      # @param datetime [DateTime] The message date time
      # @param progname [DateTime] The program name
      # @param message [String] The log message
      # @param context [Hash] The log message context
      #
      # @return [String] the formatted log message
      def call(severity, datetime, progname, message, context = {})
        message = message ? msg2str(message).strip : ''
        message = context.map { |key, value| "#{key}=#{value}" }
                    .prepend(message)
                    .compact
                    .join(' ')
        super(severity, datetime, progname, message)
      end
    end
  end
end
