# frozen_string_literal: true

module MrLogaLoga
  RSpec.describe LoggerProxy do
    let(:formatter) { ->(_severity, _datetime, _progname, _message, context) { context.to_s } }

    let(:logger) { MrLogaLoga::Logger.new($stdout, formatter: formatter) }

    subject { described_class.new(logger, -> { context }) }

    context '#add' do
      let(:context) { { a: 1 } }

      it 'should log with context' do
        expect { subject.log(Logger::Severity::DEBUG, 'message') }.to output({ a: 1 }.to_s).to_stdout
      end
    end
  end
end
