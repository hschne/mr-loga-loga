# frozen_string_literal: true

require 'logger'

module MrLogaLoga
  # == Description
  #
  # A proxy that attaches contextual information to the underlying logger when called.
  #
  # @api private
  class LoggerProxy
    def initialize(logger, context_proc)
      @logger = logger
      @context_proc = context_proc
    end

    def add(severity, message = nil, **context, &block)
      severity ||= UNKNOWN
      return true unless @logger.log?(severity)

      context = @context_proc.call.merge(context)

      @logger.add(severity, message, **context, &block)
    end

    alias log add

    %i[debug info warn error fatal unknown].each do |symbol|
      define_method(symbol) do |message = nil, **context, &block|
        severity = Object.const_get("Logger::Severity::#{symbol.to_s.upcase}")
        return true unless @logger.log?(severity)

        context = @context_proc.call.merge(context)

        @logger.public_send(symbol, message, **context, &block)
      end
    end
  end
end
