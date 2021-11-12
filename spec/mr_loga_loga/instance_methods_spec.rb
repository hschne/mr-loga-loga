# frozen_string_literal: true

module MrLogaLoga
  RSpec.describe InstanceMethods do
    let(:formatter) { ->(_severity, _datetime, _progname, _message = nil, context) { context.to_s } }

    let(:logger) { MrLogaLoga::Logger.new($stdout, formatter: formatter) }

    subject { Dummy.new(logger) }

    it 'should write log context' do
      expect { subject.loga_loga.error('message') }.to output({ class_name: 'Dummy' }.to_s).to_stdout
    end

    context 'logger' do
      it 'returns logger proxy of logger' do
        expect(subject.logger).to be_a(MrLogaLoga::LoggerProxy)
      end
    end

    context 'unknown method' do
      it 'should raise error' do
        expect { subject.loga_loga.invalid }.to raise_error(NoMethodError)
      end
    end
  end
end
