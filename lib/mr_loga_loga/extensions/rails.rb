# frozen_string_literal: true

module MrLogaLoga
  module Extensions
    # == Description
    #
    # This patches Rails to allow it to work with loggers that accept keyword arguments.
    #
    # Per default, Rails patches any logger during server startup to be able to broadcast any log messages to the
    # console. This patch assumes that loggers only take args and blocks, so we have to change that.
    #
    # During server startup Rails will always use the ActiveSupport::Logger to send data to the console.
    # This was modified o changed to always use the user-configured logger.
    #
    # == Patches
    #
    # - {ActiveSupport::Logger#self.broadcast}
    # - {Rails::Server#log_to_stdout}
    #
    module RailsExtension
      class << self
        def apply
          return unless defined?(Rails)

          patch_logger
          patch_server
        end

        private

        def patch_server
          server_defined = defined?(Rails::Server)
          return unless server_defined

          unless Rails::Server.private_method_defined?(:log_to_stdout)
            puts "WARNING: Failed to patch Rails::Server. It looks like MrLogaLoga's patch in #{__FILE__} no "\
                 "longer applies. Please contact MrLogaLoga's maintainers."
            return
          end

          Rails::Server.prepend(ServerPatch)
        end

        def patch_logger
          logger_defined = defined?(ActiveSupport::Logger)
          return unless logger_defined

          unless broadcast_method
            puts "WARNING: Failed to patch ActiveSupport::Logger. It looks like MrLogaLoga's patch in #{__FILE__} no "\
                 "longer applies. Please contact MrLogaLoga's maintainers."
            return
          end

          ActiveSupport::Logger.include(LoggerPatch)
        end

        def broadcast_method
          broadcast = ActiveSupport::Logger.method(:broadcast)
          broadcast && broadcast.arity == 1
        rescue NameError
          false
        end

        # This patches ActiveSupport::Logger to allow properly formatting keyword arguments
        module LoggerPatch
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
                    logger.add(*args, **kwargs, &block)
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

        # This patches the server command so that console output will use the same logger you previously configured
        module ServerPatch
          def log_to_stdout
            wrapped_app # touch the app so the logger is set up

            console = Rails.logger.class.new(STDOUT)
            console.formatter = Rails.logger.formatter
            console.level = Rails.logger.level

            unless ActiveSupport::Logger.logger_outputs_to?(Rails.logger, STDOUT)
              Rails.logger.extend(ActiveSupport::Logger.broadcast(console))
            end
          end
        end
      end
    end
  end
end

MrLogaLoga::Extensions::RailsExtension.apply
