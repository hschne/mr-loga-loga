# frozen_string_literal: true

module MrLogaLoga
  module Formatters
    RSpec.describe Json do
      before { Timecop.freeze(Time.local(2020)) }

      after { Timecop.return }

      it 'should format as json' do
        expected = {
          severity: 'DEBUG',
          datetime: '2020-01-01T00:00:00.000000',
          pid: Process.pid,
          progname: 'progname',
          message: 'message',
          key1: 'key1',
          key2: 2
        }
        expected = "#{expected.to_json}\n"
        expect(subject.call('DEBUG', Time.now, 'progname', 'message', { key1: 'key1', key2: 2 }))
          .to eq(expected)
      end

      it 'should ignore nil values' do
        expected = {
          severity: 'DEBUG',
          datetime: '2020-01-01T00:00:00.000000',
          pid: Process.pid,
          progname: 'progname'
        }
        expected = "#{expected.to_json}\n"
        expect(subject.call('DEBUG', Time.now, 'progname', nil, {}))
          .to eq(expected)
      end
    end
  end
end
