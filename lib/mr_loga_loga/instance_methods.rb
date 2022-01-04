# frozen_string_literal: true

module MrLogaLoga
  # == Description
  #
  # Instance methods to be attached when including the main module.
  #
  # @api private
  module InstanceMethods
    def loga_context
      { class_name: self.class.name }
    end

    def logger
      if loga_loga.is_a?(MrLogaLoga::Logger)
        MrLogaLoga::LoggerProxy.new(loga_loga, -> { loga_context })
      else
        loga_loga
      end
    end

    def loga_loga
      @loga_loga ||= if defined?(Rails.logger)
                       Rails.logger
                     else
                       MrLogaLoga.configuration.logger
                     end
    end
  end
end
