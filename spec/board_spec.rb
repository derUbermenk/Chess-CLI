# frozen_string_literal: true
require_relative '../lib/board'

describe Board do 
  describe '#initialize' do
    subject(:board) { described_class.new }

    before do
    end

    context 'when creating the board database' do
      it 'creates a hash with values that are of type cell' do
        board_elements = board.board_db.values
        expect(board_elements).to all(be_a(Cell))
      end

      it 'creates a board database with 64 cells' do 
        board_db = board.board_db

        expect(board_db).to have(64).cells
      end
    end

    context 'when creating the board cartesian' do
      it 'creates a 8 x 8 array' do
        expect(board_cartesian).to have(8).cells
        expect(board_cartesian).to all(have(8).cells)
      end

      it 'sets cells in the proper coordinate' do
        board_cartesian = board.board_cartesian
        origin00 = board_cartesian[0][0].key
        topleft07 = board_cartesian[0][7].key
        bottomright70 = board_cartesian[7][0].key
        topright77 = board_cartesian[7][7].key

        expected_keys = %i[a1 a8 h1 h8]
        expect([origin00, topleft07, bottomright70, topright77]).to be(expected_keys)
      end
    end

    context 'when setting the pieces' do
      it 'sets white pawns at the second row and black pawns at 7th row' do
        second_row_pieces = board.board_cartesian[1].map(&:piece[0])
        second_row_color = second_row_pieces.map(&:color)
        seventh_row_pieces = board.board_cartesian[6].map(&:piece[0])
        seventh_row_color = seventh_row_pieces.map(&:color)

        expect(second_row_pieces).to all(be_a(Pawn))
        expect(second_row_color).to all(eq(:white))
        expect(seventh_row_pieces).to all(be_a(Pawn))
        expect(seventh_row_color).to all(eq(:black))
      end

      it 'sets the non pawn pieces in proper order' do
        proper_order = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

        white_non_pawn_order = board.board_cartesian[0].map(&:class)
        black_non_pawn_order = board.board_cartesian[7].map(&:class)

        expect(white_non_pawn_order).to be(proper_order)
        expect(black_non_pawn_order).to be(proper_order)
      end
    end
  end

  describe '#move_piece' do
    it 'remaps connections' do; end

    context 'capture' do
      context 'when moving a rook from d4 to d7, with d7 occupied by opposite color'
        it "replaces the piece of the target cell
          with the piece of the source cell" do
          d7 = board.board_db[:d7]
          expect { board.move_piece(:d4, :d7) }.to change { d7.piece[0].class }.to(Rook)
        end

        it 'removes the rook from d4' do
          d4 = board.board_db[:d4]
          expect { board.move_piece(:d4, :d7) }.to change { d4.piece }.to([])
        end
      end
    end

    context 'place' do; end
  end

  describe '#removal_remap' do
    it 'remaps all connections referencing the cell' do; end

    it "removes references to the cell in all @from_connection 
    referenced in self.to_connections" do; end

    it "recalculates the path passing through self and 
    all cells referencing it self in @to_connections" do; end
  end

  describe '#placement_remap' do
    it 'remaps all connections referencing the cell' do; end

    it 'adds references to self for all cells in self.to_connections' do; end

    it "recalculates the path passing through self and all cells referencing it
    in cell.to_connections" do; end
  end
end
