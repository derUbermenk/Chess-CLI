# frozen_string_literal: true

require_relative '../lib/board_elements/cell'
require_relative '../lib/board'

describe Cell do 
  describe '#connect' do
    context 'when a piece with a king is in c4' do
      it 'sets the c4.to_connections to all the cells +1 unit from c4' do
        sq = :square
        c4 = Cell.new(:c4, sq)
        expected_connections = [
          { d4: Cell.new(:d4, sq) },
          { d5: Cell.new(:d5, sq) },
          { c5: Cell.new(:c5, sq) },
          { b5: Cell.new(:b5, sq) },
          { b4: Cell.new(:b4, sq) },
          { b3: Cell.new(:b3, sq) },
          { c3: Cell.new(:c3, sq) },
          { d3: Cell.new(:d3, sq) },
        ]

        expect{ c4.connect(expected_connections) }.to change { c4.to_connections }.to(expected_connections)
      end

      it 'adds self with self.key as key for the from_connections of all the 
      to_connections of self' do
        sq = :square
        c4 = Cell.new(:c4, sq)
        expected_connections = [
          { d4: Cell.new(:d4, sq) },
          { d5: Cell.new(:d5, sq) },
          { c5: Cell.new(:c5, sq) },
          { b5: Cell.new(:b5, sq) },
          { b4: Cell.new(:b4, sq) },
          { b3: Cell.new(:b3, sq) },
          { c3: Cell.new(:c3, sq) },
          { d3: Cell.new(:d3, sq) },
        ]

        c4.connect(expected_connections)

        expected_connections.each do |direction|
          direction.each { |key, cell| expect(cell.from_connections[:c4]).to eq(c4) }
        end

      end
    end
  end

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