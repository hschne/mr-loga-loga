# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MrLogaLoga do
  it 'has a version number' do
    expect(MrLogaLoga::VERSION).not_to be nil
  end

  describe 'logging' do
    let(:logger) { MrLogaLoga::Logger.new($stdout) }

    let(:time) { Time.now.strftime('%Y-%m-%dT%H:%M:%S.%6N ') }

    before { Timecop.freeze(Time.local(2020)) }

    after { Timecop.return }

    describe 'configure' do
      let(:logger) { Logger.new($stdout) }

      before do
        MrLogaLoga.configure do |config|
          config.logger = logger
        end
      end

      after { MrLogaLoga.configuration.reset }

      it 'should configure logger' do
        expect(MrLogaLoga.configuration.logger).to eq(logger)
      end
    end

    describe 'context' do
      let(:log_message) { "D, [#{time}##{Process.pid}] DEBUG -- : message a=1\n" }

      it 'should log with hash context' do
        expect { logger.debug('message', a: 1) }.to output(log_message).to_stdout
      end

      it 'should log with explicit context' do
        expect { logger.context(a: 1).debug('message') }.to output(log_message).to_stdout
      end

      it 'should log with block context' do
        expect { logger.context { { a: 1 } }.debug('message') }.to output(log_message).to_stdout
      end

      it 'should log with block context' do
        expect { logger.context { { a: 1 } }.debug('message') }.to output(log_message).to_stdout
      end

      it 'should log with dynamic context' do
        expect { logger.a(1).debug('message') }.to output(log_message).to_stdout
      end

      it 'should log with dynamic block context' do
        expect { logger.a { 1 }.debug('message') }.to output(log_message).to_stdout
      end
    end
  end
end
