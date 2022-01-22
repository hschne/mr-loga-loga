# frozen_string_literal: true

module MrLogaLoga
  module Formatters
    RSpec.describe KeyValue do
      before { Timecop.freeze(Time.local(2020)) }

      after { Timecop.return }

      it 'should format as key value' do
        expected = "D, [2020-01-01T00:00:00.000000 ##{Process.pid}] DEBUG -- progname: message key1=key1 key2=2\n"
        expect(subject.call('DEBUG', Time.now, 'progname', 'message', key1: 'key1', key2: 2))
          .to eq(expected)
      end

      it 'should format exceptions' do
        expected = "D, [2020-01-01T00:00:00.000000 ##{Process.pid}] DEBUG -- progname: error (StandardError) key1=1\n"
        expect(subject.call('DEBUG', Time.now, 'progname', StandardError.new('error'), key1: '1'))
          .to eq(expected)
      end

      it 'should work with non-strings' do
        expected = "D, [2020-01-01T00:00:00.000000 ##{Process.pid}] DEBUG -- progname: 200\n"
        expect(subject.call('DEBUG', Time.now, 'progname', 200))
          .to eq(expected)
      end
    end
  end
end
