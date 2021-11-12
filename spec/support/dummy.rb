# frozen_string_literal: true

class Dummy
  include MrLogaLoga

  def initialize(logger)
    @loga_loga = MrLogaLoga::LoggerProxy.new(logger, -> { loga_context })
  end
end
