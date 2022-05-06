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
  #
  class Logger < ::Logger
    alias super_add add

    def initialize(*args, **kwargs)
      super
      @default_formatter = MrLogaLoga::Formatters::KeyValue.new
    end

    # Generates a new context
    def context(context = {}, &block)
      result = block ? -> { context.merge(block.call) } : context
      Context.new(self, result)
    end

    # Adds a new log message with the given severity
    def add(severity, message = nil, context = nil, progname = nil, &block)
      write(severity, message, context, progname, &block)
    end

    # Write the actual log data
    #
    # This method needs to be used rather than add as various gems (Rails, Sidekiq) patch loggers to overwrite add. The
    # patches' signatures do not match our add method, so we use this method to do the actual logging in helper methods
    # like debug, info etc.
    #
    def write(severity, *args, &block)
      severity ||= UNKNOWN
      return true unless log?(severity)

      message, context, progname = args
      log_message = message.is_a?(LogMessage) ? message : LogMessage.new(*LoggerData.build(message, context, &block))

      super_add(severity, log_message, progname)
    end

    alias log add

    %i[debug info warn error fatal unknown].each do |symbol|
      define_method(symbol) do |message = nil, context = nil, progname = nil, &block|
        # Map the symbol (e.g. :debug) to the severity constant (e.g. DEBUG)
        severity = Object.const_get("Logger::Severity::#{symbol.to_s.upcase}")
        message, context = LoggerData.build(message, context, &block)

        add(severity, LogMessage.new(message, context), progname, &block)
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

    def format_message(severity, datetime, progname, message)
      (@formatter || @default_formatter).call(severity, datetime, progname, message.msg, message.context)
    end
  end
end
