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

  describe '#update_path' do
    let(:db) { Board.new(empty: true).board_db }
    let(:d4) { db[:d4] }
    context 'when a new path has been calculated for d4 for the path containing d3' do
      before do
        d4.to_connections = [
          { d3: db[:d3], d2: db[:d2] },
          { c4: db[:c4], b4: db[:b4] }
        ]
      end

      it 'updates the path containing the given cell with the new path' do
        new_path = { d3: db[:d3], d2: db[:d2], d1: db[:d1] }
        new_connections = [new_path, { c4: db[:c4], b4: db[:b4] }]
        expect { d4.update_path(:d3, new_path) }.to change { d4.to_connections }.to(new_connections)
      end
    end
  end

  describe '#checking_cells' do
    let(:a4) { Cell.new(:a4, :sq) }
    let(:b4) { Cell.new(:b4, :sq) }
    let(:a5) { Cell.new(:a5, :sq) }
    let(:c5) { Cell.new(:c5, :sq) }

    before do
      b4.piece = Rook.new(:white)
      a5.piece = Pawn.new(:white)
      c5.piece = King.new(:black)

      a4.from_connections = { b4: b4, a5: a5, c5: c5 }
    end

    it 'returns all the from_connections containing the given a piece of the given color' do
      expect(a4.checking_cells(:white)).to eq({ b4: b4, a5: a5 })
    end
  end

  describe '#not_checked_by' do
    context "when self is checked has a from connection with a cell containing a black piece and 
      no other connection" do
      context 'when checking if it is not in check by a black piece' do
        it 'returns false' do
          a8 = Cell.new(:a8, :square)
          a8.piece = Rook.new(:black)
          a7 = Cell.new(:a7, :square)
          a7.from_connections = { a8: a8 }

          expect(a7.not_checked_by(:black)).to be false
        end
      end

      context 'when checking if it is not in check by a white piece' do
        it 'returns true' do
          a8 = Cell.new(:a8, :square)
          a8.piece = Rook.new(:black)
          a7 = Cell.new(:a7, :square)
          a7.from_connections = { a8: a8 }

          expect(a7.not_checked_by(:white)).to be true 
        end
      end
    end

    context "when self is checked has a from connection with a cell containing a white piece and 
      no other connection" do
      context 'when checking if it is not in check by a black piece' do
        it 'returns true' do
          a8 = Cell.new(:a8, :square)
          a8.piece = Rook.new(:white)
          a7 = Cell.new(:a7, :square)
          a7.from_connections = { a8: a8 }

          expect(a7.not_checked_by(:black)).to be true 
        end
      end

      context 'when checking if it is not in check by a white piece' do
        it 'returns false' do
          a8 = Cell.new(:a8, :square)
          a8.piece = Rook.new(:white)
          a7 = Cell.new(:a7, :square)
          a7.from_connections = { a8: a8 }

          expect(a7.not_checked_by(:white)).to be false 
        end
      end
    end
  end

  describe '#occupiable_by' do 
    context 'when a cell is empty' do
      it 'is occupiable by both black and white colors' do
        colors = %i[white black]
        a7 = Cell.new(:a7, :square)

        colors.each do |color|
          expect(a7.occupiable_by(color)).to be true
        end 
      end
    end

    context 'when a cell has a black piece' do
      it 'is occupiable by white pieces' do
        a7 = Cell.new(:a7, :square)
        a7.piece = Rook.new(:black)

        expect(a7.occupiable_by(:white)).to be true
      end

      it 'is not occupiable by black pieces' do
        a7 = Cell.new(:a7, :square)
        a7.piece = Rook.new(:black)

        expect(a7.occupiable_by(:black)).to be false
      end
    end
  end
end
