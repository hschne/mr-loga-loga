# frozen_string_literal: true

module MrLogaLoga
  module Adapters
    # This patches Lograge to forward data as context to MrLogaLoga
    #
    module ActiveSupportLoggerPatch
      class << self
        def apply
          return unless defined?(ActiveSupport)

          patch_applies = defined?(ActiveSupport::Logger)
          unless patch_applies
            puts 'WARNING: Failed to patch ActiveSupprt::Logger. It looks like '\
                 "MrLogaLoga's patch no longer applies in "\
                 "#{__FILE__}. Please contact MrLogaLoga maintainers."
            return
          end

          ActiveSupport::Logger.send(:include, self)
        end

        # rubocop:disable all
        def included base
          base.instance_eval do
            def broadcast(logger)
              Module.new do
                # We need to patch this method as otherwise calling add with keyword arguments results in argument errors.
                # Rails calls `broadcast` for the logger configured in `Rails.logger`, which means that any invocations of
                # Rails.logger.add result in running through this method.
                #
                # TODO: Remove once patched in Rails
                define_method(:add) do |*args, **kwargs, &block|
                  logger.add(*args, &block)
                  super(*args, **kwargs, &block)
                end

                define_method(:<<) do |x|
                  logger << x
                  super(x)
                end

                define_method(:close) do
                  logger.close
                  super()
                end

                define_method(:progname=) do |name|
                  logger.progname = name
                  super(name)
                end

                define_method(:formatter=) do |formatter|
                  logger.formatter = formatter
                  super(formatter)
                end

                define_method(:level=) do |level|
                  logger.level = level
                  super(level)
                end

                define_method(:local_level=) do |level|
                  logger.local_level = level if logger.respond_to?(:local_level=)
                  super(level) if respond_to?(:local_level=)
                end

                define_method(:silence) do |level = Logger::ERROR, &block|
                  if logger.respond_to?(:silence)
                    logger.silence(level) do
                      if defined?(super)
                        super(level, &block)
                      else
                        block.call(self)
                      end
                    end
                  else
                    if defined?(super)
                      super(level, &block)
                    else
                      block.call(self)
                    end
                  end
                end
              end
            end
          end
        end
        # rubocpo:enable all
      end
    end
  end
end

MrLogaLoga::Adapters::ActiveSupportLoggerPatch.apply
