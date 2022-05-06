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

    # A shorthand method to use in your classes
    def logger
      if loga_loga.is_a?(MrLogaLoga::Logger)
        loga_loga.context { loga_context }
      else
        loga_loga
      end
    end

    # Define the underlying logger to be used. Overwrite this to use a specific logger instance
    def loga_loga
      @loga_loga ||= if defined?(Rails.logger)
                       Rails.logger
                     else
                       MrLogaLoga.configuration.logger
                     end
    end
  end
end
