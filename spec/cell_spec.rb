# frozen_string_literal: true

require_relative '../lib/board_elements/cell'

describe Cell do 
  describe '#disconnect' do
    context 'when a a1 is initially connected to b4, b5' do
      it 'removes the refs to a1 in the from_connections of b4 and b5' do
        a1 = Cell.new(:a1, 'square')
        b4 = Cell.new(:b4, 'square')
        b5 = Cell.new(:b5, 'square')

        a1.to_connections = [{ b4: b4 }]
        b4.from_connections = {a1: a1, b5: b5}

        expect { a1.disconnect }.to change { b4.from_connections }.to({ b5: b5 })
      end
    end
  end

  describe '#occupiable_by' do; end
end