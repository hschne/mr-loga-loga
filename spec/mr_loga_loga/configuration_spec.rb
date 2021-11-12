# frozen_string_literal: true

module MrLogaLoga
  RSpec.describe Configuration do
    let(:logger) { Logger.new($stdout) }

    subject { described_class.new(logger: logger) }

    describe '#initialize' do
      it 'should set logger' do
        expect(subject.logger).to eq(logger)
      end
    end
  end
end
