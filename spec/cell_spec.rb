# frozen_string_literal: true

require_relative '../lib/board_elements/cell'
require_relative '../lib/board'

describe Cell do 
  describe '#checking_cells' do
    let(:a4) { Cell.new(:a4, :sq) }
    let(:white_rook) { Rook.new(:white) }
    let(:white_pawn) { Pawn.new(:white) }
    let(:black_king) { King.new(:black) }

    it 'returns all the from_connections containing the given a piece of the given color' do
      a4.from_connections = { b4: white_rook, a5: white_pawn, c5: black_king }
      expect(a4.checking_cells(:white)).to eq({ b4: white_rook, a5: white_pawn})
    end
  end

  describe '#not_checked_by' do
    context "when self is checked has a from connection with a cell containing a black piece and 
      no other connection" do
      context 'when checking if it is not in check by a black piece' do
        it 'returns false' do
          a7 = Cell.new(:a7, :square)
          a7.from_connections = { a8: Rook.new(:black) }

          expect(a7.not_checked_by(:black)).to be false
        end
      end

      context 'when checking if it is not in check by a white piece' do
        it 'returns true' do
          a7 = Cell.new(:a7, :square)
          a7.from_connections = { a8: Rook.new(:black) }

          expect(a7.not_checked_by(:white)).to be true 
        end
      end
    end

    context "when self is checked has a from connection with a cell containing a white piece and 
      no other connection" do
      context 'when checking if it is not in check by a black piece' do
        it 'returns true' do
          a7 = Cell.new(:a7, :square)
          a7.from_connections = { a8: Rook.new(:white) }

          expect(a7.not_checked_by(:black)).to be true 
        end
      end

      context 'when checking if it is not in check by a white piece' do
        it 'returns false' do
          a7 = Cell.new(:a7, :square)
          a7.from_connections = { a8: Rook.new(:white) }

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
