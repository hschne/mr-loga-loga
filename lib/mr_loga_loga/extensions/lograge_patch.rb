# frozen_string_literal: true

module MrLogaLoga
  module Adapters
    # This patches Lograge to forward data as context to MrLogaLoga
    module LogragePatch
      class << self
        def apply
          return unless defined?(Lograge)

          patch_applies = defined?(Lograge::LogSubscribers::Base) &&
                          Lograge::LogSubscribers::Base.private_method_defined?(:process_main_event)
          unless patch_applies
            puts 'WARNING: Failed to patch Lograge. It looks like '\
                 "MrLogaLoga's patch no longer applies in "\
                 "#{__FILE__}. Please contact MrLogaLoga maintainers."
            return
          end

          Lograge::LogSubscribers::Base.prepend(self)
        end
      end

      def process_main_event(event)
        return if Lograge.ignore?(event)

        payload = event.payload
        data = extract_request(event, payload)
        data = before_format(data, payload)
        if logger.is_a?(MrLogaLoga::Logger)
          logger.send(Lograge.log_level, '', **data)
        else
          formatted_message = Lograge.formatter.call(data)
          logger.send(Lograge.log_level, formatted_message)
        end
      end
    end
  end
end

MrLogaLoga::Adapters::LogragePatch.apply
