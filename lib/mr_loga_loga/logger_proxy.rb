# frozen_string_literal: true

require 'logger'
require 'forwardable'

module MrLogaLoga
  # == Description
  #
  # A proxy that attaches contextual information to the underlying logger when called.
  #
  # @api private
  class LoggerProxy
    extend Forwardable

    def initialize(logger, context_proc)
      @logger = logger
      @context_proc = context_proc
    end

    def add(severity, message = nil, progname = nil, **context, &block)
      severity ||= UNKNOWN
      return true unless @logger.log?(severity)

      context = @context_proc.call.merge(context)

      @logger.add(severity, message, progname, **context, &block)
    end

    alias log add

    %i[debug info warn error fatal unknown].each do |symbol|
      def_delegator :@logger, "#{symbol}?".to_sym, "#{symbol}?".to_sym

      define_method(symbol) do |progname = nil, **context, &block|
        severity = Object.const_get("Logger::Severity::#{symbol.to_s.upcase}")
        add(severity, nil, progname, **context, &block)
      end
    end
  end
end
