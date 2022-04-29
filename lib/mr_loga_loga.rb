# frozen_string_literal: true

require_relative 'mr_loga_loga/version'
require_relative 'mr_loga_loga/configuration'
require_relative 'mr_loga_loga/instance_methods'
require_relative 'mr_loga_loga/logger_data'
require_relative 'mr_loga_loga/log_message'
require_relative 'mr_loga_loga/context'
require_relative 'mr_loga_loga/logger'
require_relative 'mr_loga_loga/formatters/key_value'
require_relative 'mr_loga_loga/formatters/json'

# ## Description
#
# The MrLogaLoga module provides additional logging functionality when included in your classes.
#
module MrLogaLoga
  class Error < StandardError; end

  def self.included(base)
    base.send :include, InstanceMethods
  end

  class << self
    # Create a new configuration object
    #
    # @return [Configuration] a new configuration
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
