# frozen_string_literal: true

module MrLogaLoga
  module Formatters
    # == Description
    #
    # A simple Json formatter for MrLogaLoga.
    #
    # == Format
    #
    # The json formatter renders messages into a single-line json. Context keys are embedded on the top level.
    #
    # Log Format:
    #
    #   { "severity": "Severity", .. "message": "Message", "key1": "Key1" }
    #
    class Json < Logger::Formatter
      # Render a log message in JSON
      #
      # @param severity [String] The message severity
      # @param datetime [DateTime] The message date time
      # @param progname [DateTime] The program name
      # @param message [Object] The log message, which may not be a string
      # @param context [Hash] The log message context
      #
      # @return [String] the formatted log message
      def call(severity, datetime, progname, message, **context)
        message = message.nil? ? '' : msg2str(message)

        message_hash = {
          severity: severity,
          datetime: datetime.strftime('%Y-%m-%dT%H:%M:%S.%6N'),
          pid: Process.pid,
          progname: progname,
          message: (message.empty? ? nil : message),
          **context
        }.compact
        "#{message_hash.to_json}\n"
      end
    end
  end
end
