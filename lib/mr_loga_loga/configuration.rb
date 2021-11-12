# frozen_string_literal: true

module MrLogaLoga
  # == Description
  #
  # The configuration class for MrLogaLoga
  #
  # == Usage
  #
  #   MrLogaLoga.configure do |configuration|
  #     configuration.logger = ...
  #   end
  class Configuration
    attr_accessor :logger

    # Initialize the configuration by setting configuration default values
    def initialize(**kwargs)
      reset
      kwargs.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    # Reset the configuration to default values
    def reset
      @logger = MrLogaLoga::Logger.new($stdout)
    end
  end
end
