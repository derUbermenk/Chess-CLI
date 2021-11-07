# frozen_string_literal: true
require_relative '../lib/board'

describe SetupInstructions do
  let(:dummy_board) { Board.new(empty: true)}

  describe '#create_board_db' do
    it 'creates a board database with values that are of type cell' do
      board_db = dummy_board.create_board_db
      expect(board_db.values).to all(be_a(Cell))
    end

    it 'creates a board database with 64 cells' do 
      board_db = dummy_board.create_board_db
      expect(board_db.size).to eq(64)
    end
  end

  describe '#create_board_cartesian' do
    it 'creates a 8 x 8 array where each array contains cells' do
      board_cartesian = dummy_board.create_board_cartesian
      expect(board_cartesian.size).to eq(8)
      expect(board_cartesian).to all(be_a(Array))

      board_cartesian.each do |row|
        expect(row).to be_a(Array).and all(be_a(Cell))
        expect(row.size).to eq(8)
      end
    end

    it 'places the cells in the correct positions' do
      # positions are queried via board_cartesian[y][x] -- row, column
      board_cartesian = dummy_board.create_board_cartesian
      # indexing is of board cartesian is by [y][x]
      a1 = board_cartesian[0][0]
      c4 = board_cartesian[3][2]
      g6 = board_cartesian[5][6]
      h8 = board_cartesian[7][7]

      queries = [a1, c4, g6, h8]
      expect(queries.map(&:key)).to eq(%i[a1 c4 g6 h8])
    end
  end

  describe '#create_pieces' do
    it 'initializes the pieces with correct count and colors' do; end
  end

  describe '#place_pieces' do
    let(:board) { Board.new }
    it 'sets white pawns at the 2nd row and black pawns at 7th row' do

      second_row_pieces = board.board_cartesian[1].map(&:piece)
      second_row_color = second_row_pieces.map(&:color)
      seventh_row_pieces = board.board_cartesian[6].map(&:piece)
      seventh_row_color = seventh_row_pieces.map(&:color)

      expect(second_row_pieces).to all(be_a(Pawn))
      expect(second_row_color).to all(eq(:white))
      expect(seventh_row_pieces).to all(be_a(Pawn))
      expect(seventh_row_color).to all(eq(:black))
    end

    it 'sets the non pawn pieces in proper order' do
      proper_order = [Rook, Knight, Bishop, Queen,
                      King, Bishop, Knight, Rook]

      first_row = board.board_cartesian[0]
      last_row = board.board_cartesian[7]

      get_pieces = ->(row) { row.map { |cell| cell.piece.class } }

      white_non_pawn_order = get_pieces.call(first_row) 

      black_non_pawn_order = get_pieces.call(last_row) 

      expect(white_non_pawn_order).to eq(proper_order)
      expect(black_non_pawn_order).to eq(proper_order)
    end
  end
end
