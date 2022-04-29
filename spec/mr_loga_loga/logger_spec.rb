# frozen_string_literal: true

module MrLogaLoga
  RSpec.describe Logger do
    subject { described_class.new($stdout, formatter: formatter) }

    let(:formatter) { ->(severity, _datetime, _progname, message, _context) { "#{severity} #{message}" } }

    describe '#add' do
      context 'level' do
        let(:formatter) { ->(severity, _datetime, _progname, _message, _context) { severity } }

        subject { described_class.new($stdout, formatter: formatter, level: 3) }

        it 'should log with higher severity' do
          expect { subject.log(Logger::Severity::ERROR) }.to output('ERROR').to_stdout
        end

        it 'should not log with lower severity' do
          expect { subject.log(Logger::Severity::WARN) }.to_not output.to_stdout
        end
      end

      context 'severity' do
        let(:formatter) { ->(severity, _datetime, _progname, _message, _context) { severity } }

        it 'should log severity' do
          expect { subject.log(Logger::Severity::DEBUG, 'message') }.to output('DEBUG').to_stdout
        end
      end

      context 'date time' do
        let(:formatter) { ->(_severity, datetime, _progname, _message, _context) { datetime.to_s } }

        it 'should log time' do
          expect { subject.log(Logger::Severity::DEBUG, 'message') }.to output(Time.now.to_s).to_stdout
        end
      end

      context 'message' do
        let(:formatter) { ->(_severity, _datetime, _progname, message, _context) { message } }

        it 'should log message' do
          expect { subject.log(Logger::Severity::DEBUG, 'message') }.to output('message').to_stdout
        end

        context 'missing' do
          it 'should log nothing' do
            expect { subject.log(Logger::Severity::DEBUG) }.to output('').to_stdout
          end
        end

        context 'block' do
          it 'should log message' do
            expect { subject.log(Logger::Severity::DEBUG) { 'message' } }.to output('message').to_stdout
          end

          it 'should overwrite arg message' do
            expect { subject.log(Logger::Severity::DEBUG, 'arg') { 'message' } }.to output('message').to_stdout
          end
        end
      end

      context 'context' do
        let(:formatter) do
          lambda { |_severity, _datetime, _progname, message, context|
            [message, context].compact.join(',')
          }
        end

        it 'should log kwargs context' do
          context = { a: 1, b: 2 }
          expect { subject.log(Logger::Severity::DEBUG, context) }.to output(context.to_s).to_stdout
        end

        it 'should log explicit context' do
          context = { a: 1, b: 2 }
          expect { subject.context(context).debug('message') }.to output("message,#{context}").to_stdout
        end
      end
    end

    describe '#method_missing' do
      let(:formatter) { ->(_severity, _datetime, _progname, _message, context) { context.to_s } }

      it 'should log args' do
        context = { a: 1 }
        expect { subject.a(1).add(Logger::Severity::DEBUG) }.to output(context.to_s).to_stdout
      end

      it 'should log block' do
        context = { a: 1 }
        expect { subject.a { 1 }.add(Logger::Severity::DEBUG) }.to output(context.to_s).to_stdout
      end

      it 'should log block over arg' do
        context = { a: 1 }
        expect { subject.a(2) { 1 }.add(Logger::Severity::DEBUG) }.to output(context.to_s).to_stdout
      end
    end

    describe '#log?' do
      context 'without log dev' do
        subject { described_class.new(nil, formatter: formatter) }

        it 'should return false' do
          expect(subject.log?(Logger::Severity::DEBUG)).to be(false)
        end
      end

      context 'with log level higher' do
        subject { described_class.new($stdout, formatter: formatter, level: 3) }

        it 'should return false' do
          expect(subject.log?(Logger::Severity::WARN)).to be(false)
        end
      end

      context 'with log level lower' do
        subject { described_class.new($stdout, formatter: formatter, level: 3) }

        it 'should return true' do
          expect(subject.log?(Logger::Severity::ERROR)).to be(true)
        end
      end
    end

    context '#debug' do
      it 'should use severity' do
        expect { subject.debug('message') }.to output('DEBUG message').to_stdout
      end
    end

    context '#info' do
      it 'should use severity' do
        expect { subject.info('message') }.to output('INFO message').to_stdout
      end
    end

    context '#warn' do
      it 'should use severity' do
        expect { subject.warn('message') }.to output('WARN message').to_stdout
      end
    end

    context '#error' do
      it 'should use severity' do
        expect { subject.error('message') }.to output('ERROR message').to_stdout
      end
    end

    context '#fatal' do
      it 'should use severity' do
        expect { subject.fatal('message') }.to output('FATAL message').to_stdout
      end
    end

    context '#unknown' do
      it 'should use severity' do
        expect { subject.unknown('message') }.to output('ANY message').to_stdout
      end
    end
  end
end
