# frozen_string_literal: true

require 'delegate'

module MrLogaLoga
  # == Description
  #
  # This class provides a fluent interface to attach contextual information to log messages.
  class Context
    def initialize(logger, context = {})
      @logger = logger
      @context = context
    end

    # Add a new context to the log message
    #
    # @param context [Hash] the new context
    # @yield the new context
    # @return [Context] a new context object
    def context(context = {}, &block)
      @context = merge_context(@context, context)
      @context = merge_context(@context, block)
      self
    end

    # Log a message with the current context
    #
    # @param context [Hash] the new context
    # @yield the new context
    # @return [Context] a new context object
    def add(severity, message = nil, context = nil, progname = nil, &block)
      severity ||= UNKNOWN
      return true unless @logger.log?(severity)

      message, context = LoggerData.build(message, context, &block)
      context = merge_context(@context, context)
      context = context.call if context.is_a?(Proc)

      @logger.add(severity, LogMessage.new(message, context), progname, &block)
    end

    alias log add

    %i[debug info warn error fatal unknown].each do |symbol|
      define_method(symbol) do |message = nil, context = nil, progname = nil, &block|
        severity = Object.const_get("Logger::Severity::#{symbol.to_s.upcase}")
        return true unless @logger.log?(severity)

        message, context = LoggerData.build(message, context, &block)
        context = merge_context(@context, context)
        context = context.call if context.is_a?(Proc)

        @logger.add(severity, LogMessage.new(message, context), progname, &block)
      end
    end

    def method_missing(symbol, *args, &block)
      context = block ? -> { { symbol => block.call } } : { symbol => unwrap(args) }
      @context = merge_context(@context, context)
      self
    end

    def respond_to_missing?(name, include_private = false)
      super(name, include_private)
    end

    private

    def unwrap(args)
      if args.size == 1
        args[0]
      else
        args
      end
    end

    def merge_context(original, new)
      return original unless new

      return original.merge(new) if original.is_a?(Hash) && new.is_a?(Hash)

      merge_blocks(original, new)
    end

    def merge_blocks(original, new)
      return -> { original.merge(new.call) } if original.is_a?(Hash) && new.is_a?(Proc)

      return -> { original.call.merge(new) } if original.is_a?(Proc) && new.is_a?(Hash)

      -> { original.call.merge(new.call) }
    end
  end
end
