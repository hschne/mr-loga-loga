# frozen_string_literal: true

require 'logger'

module MrLogaLoga
  # == Description
  #
  # This class separates message and contextual data from args
  class LoggerData
    class << self
      def build(*args, &block)
        args = block ? block.call : args
        msg, context = args
        if msg.nil?
          [nil, as_hash(context)]
        elsif context.nil?
          msg.is_a?(Hash) ? [nil, msg] : [msg, {}]
        else
          [msg, as_hash(context)]
        end
      end

      private

      def as_hash(data)
        if data.is_a?(Hash) || data.respond_to?(:to_hash)
          data
        elsif !data.nil?
          { context: data }
        else
          {}
        end
      end
    end
  end
end
