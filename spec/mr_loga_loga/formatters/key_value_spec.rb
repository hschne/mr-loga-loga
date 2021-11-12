# frozen_string_literal: true

module MrLogaLoga
  module Formatters
    RSpec.describe KeyValue do
      before { Timecop.freeze(Time.local(2020)) }

      after { Timecop.return }

      it 'should format as key value' do
        expected = "D, [2020-01-01T00:00:00.000000 ##{Process.pid}] DEBUG -- progname: message key1=key1 key2=2\n"
        expect(subject.call('DEBUG', Time.now, 'progname', 'message', { key1: 'key1', key2: 2 }))
          .to eq(expected)
      end
    end
  end
end
