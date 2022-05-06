# frozen_string_literal: true

module MrLogaLoga
  RSpec.describe LoggerData do
    subject { described_class }
    describe '#build' do
      context 'with both args' do
        it 'should return message and context' do
          expect(subject.build('message', a: 1)).to eq(['message', { a: 1 }])
        end

        it 'should return message' do
          expect(subject.build('message')).to eq(['message', {}])
        end

        it 'should return context' do
          expect(subject.build({ a: 1 })).to eq([nil, { a: 1 }])
        end
      end

      context 'with block' do
        it 'should return message' do
          expect(subject.build { 'message' }).to eq(['message', {}])
        end

        it 'should return context' do
          expect(subject.build { { a: 1 } }).to eq([nil, { a: 1 }])
        end

        it 'should return message and context' do
          expect(subject.build { ['message', { a: 1 }] }).to eq(['message', { a: 1 }])
        end
      end
      context 'with nil' do
        it 'should return context' do
          expect(subject.build(nil, a: 1)).to eq([nil, { a: 1 }])
        end

        it 'should return message and context' do
          expect(subject.build('message', nil)).to eq(['message', {}])
        end
      end
    end
  end
end
