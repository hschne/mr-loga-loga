# frozen_string_literal: true

module MrLogaLoga
  RSpec.describe InstanceMethods do
    let(:formatter) { ->(_severity, _datetime, _progname, _message, data) { data.to_s } }

    let(:logger) { MrLogaLoga::Logger.new($stdout, formatter: formatter) }

    subject { Dummy.new(logger) }

    it 'should write log context' do
      expect { subject.loga_loga.error('message') }.to output({ class_name: 'Dummy' }.to_s).to_stdout
    end

    context 'logger' do
      it 'returns logger' do
        expect(subject.logger).to be_a(MrLogaLoga::Context)
      end
    end
  end
end
