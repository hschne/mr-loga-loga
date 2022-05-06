# frozen_string_literal: true

class Dummy
  include MrLogaLoga

  def initialize(logger)
    @loga_loga = logger.context { loga_context }
  end
end
