# frozen_string_literal: true

require 'logger'

module MrLogaLoga
  # == Description
  #
  # This class extends the default Ruby Logger to allow users to attach contextual information to log messages.
  #
  # === Example
  #
  # This creates a Logger that outputs to the standard output stream, with a
  # level of +WARN+:
  #
  #   require 'mr_loga_loga'
  #
  #   logger = MrLogaLoga::Logger.new(STDOUT)
  #   logger.level = Logger::WARN
  #
  #   logger.debug("Default")
  #   logger.context(user: 1).debug('with context')
  class Logger < ::Logger
    def context(**kwargs, &block)
      context = block ? -> { kwargs.merge(block.call) } : kwargs
      Context.new(self, context)
    end

    def message(message, &block)
      message ||= block
      Message.new(self, message)
    end

    def add(severity, message = nil, progname = nil, **context, &block)
      severity ||= UNKNOWN
      return true unless log?(severity)

      message = block.call if block
      @logdev.write(format(format_severity(severity), Time.now, progname, message, context))
      true
    end

    alias log add

    %i[debug info warn error fatal unknown].each do |symbol|
      define_method(symbol) do |message = nil, **context, &block|
        # Map the symbol (e.g. :debug) to the severity constant (e.g. DEBUG)
        severity = Object.const_get("Logger::Severity::#{symbol.to_s.upcase}")
        add(severity, message, **context, &block)
      end
    end

    def method_missing(symbol, *args, &block)
      context = block ? -> { { symbol => block.call } } : { symbol => unwrap(args) }
      Context.new(self, context)
    end

    def respond_to_missing?(name, include_private = false)
      super(name, include_private)
    end

    def log?(severity)
      !@logdev.nil? && severity >= level
    end

    private

    def unwrap(args)
      if args.size == 1
        args[0]
      else
        args
      end
    end

    def format(severity, datetime, progname, message, context)
      formatter.call(severity, datetime, progname, message, context)
    end

    def formatter
      @formatter ||= MrLogaLoga::Formatters::KeyValue.new
    end
  end
end
