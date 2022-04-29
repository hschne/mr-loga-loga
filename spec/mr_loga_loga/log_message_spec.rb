# frozen_string_literal: true

module MrLogaLoga
  RSpec.describe LogMessage do
    describe '#inspect' do
      it 'returns only message' do
        expect(described_class.new('message', {}).inspect).to eq("message\n")
      end
    end
  end
end
