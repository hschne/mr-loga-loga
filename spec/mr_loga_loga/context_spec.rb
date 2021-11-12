# frozen_string_literal: true

module MrLogaLoga
  RSpec.describe Context do
    let(:formatter) { ->(_severity, _datetime, _progname, _message, context) { context.to_s } }

    let(:logger) { MrLogaLoga::Logger.new($stdout, formatter: formatter) }

    let(:context) { { a: 1 } }

    subject { described_class.new(logger, context) }

    describe '#add' do
      it 'should log context' do
        expect { subject.add(Logger::Severity::DEBUG) }.to output(context.to_s).to_stdout
      end

      it 'should merge context' do
        expect { subject.add(Logger::Severity::DEBUG, b: 2) }.to output({ a: 1, b: 2 }.to_s).to_stdout
      end
    end

    describe '#debug' do
      it 'should log context' do
        expect { subject.debug }.to output(context.to_s).to_stdout
      end
    end

    describe '#context' do
      it 'should merge context' do
        expect { subject.context(b: 2).debug }.to output({ a: 1, b: 2 }.to_s).to_stdout
      end

      context 'block' do
        it 'should merge context' do
          expect { subject.context { { b: 2 } }.debug }.to output({ a: 1, b: 2 }.to_s).to_stdout
        end

        it 'should merge with kwargs' do
          expect { subject.context(b: 2) { { c: 3 } }.debug }.to output({ a: 1, b: 2, c: 3 }.to_s).to_stdout
        end

        it 'should overwrite kwargs' do
          expect { subject.context(b: 2) { { b: 3 } }.debug }.to output({ a: 1, b: 3 }.to_s).to_stdout
        end
      end
    end

    describe '#method_missing' do
      it 'should merge context' do
        expect { subject.b(2).debug }.to output({ a: 1, b: 2 }.to_s).to_stdout
      end

      it 'should merge multiple context' do
        expect { subject.b(2).c(3).debug }.to output({ a: 1, b: 2, c: 3 }.to_s).to_stdout
      end

      it 'should merge block' do
        expect { subject.b { 2 }.debug }.to output({ a: 1, b: 2 }.to_s).to_stdout
      end

      it 'should merge block over arg' do
        expect { subject.b(3) { 2 }.debug }.to output({ a: 1, b: 2 }.to_s).to_stdout
      end
    end
  end
end
