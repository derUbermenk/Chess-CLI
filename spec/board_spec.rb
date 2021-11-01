# frozen_string_literal: true
require_relative '../lib/board'

describe Board do 
  subject(:board) { described_class.new(empty: true) }
  describe '#initialize' do
    context 'when creating the board database' do
      it 'creates a board database with values that are of type cell' do
        board_elements = board.board_db.values
        expect(board_elements).to all(be_a(Cell))
      end

      it 'creates a board database with 64 cells' do 
        board_db = board.board_db

        expect(board_db.size).to eq(64)
      end
    end

    context 'when creating the board cartesian' do
      it 'creates a 8 x 8 array where each array contains cells' do
        board_cartesian = board.board_cartesian
        expect(board_cartesian.size).to eq(8)
        expect(board_cartesian).to all(be_a(Array))

        board_cartesian.each do |row|
          expect(row.size).to eq(8)
          expect(row).to be_a(Array).and all(be_a(Cell))
        end
      end

      it 'sets cells in the proper coordinate' do
        board_cartesian = board.board_cartesian
        origin = board_cartesian[0][0].key
        bottomright = board_cartesian[0][7].key
        topleft = board_cartesian[7][0].key
        topright = board_cartesian[7][7].key

        expected_keys = %i[a1 h1 a8 h8]
        expect([origin, bottomright, topleft, topright]).to eq(expected_keys)
      end
    end

    context 'when querying for a cell in board_db' do
      it 'returns the correct cell' do
        query1 = board.board_db[:a1]
        query2 = board.board_db[:h5]
        query3 = board.board_db[:e8]

        expect(query1.key).to eq(:a1)
        expect(query2.key).to eq(:h5)
        expect(query3.key).to eq(:e8)
      end
    end

    context 'when setting the pieces' do
      subject(:board) { described_class.new }
      it 'sets white pawns at the second row and black pawns at 7th row' do

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

  describe '#move_piece' do
    it 'remaps connections' do; end

    context 'capture' do
      context 'when moving a rook from d4 to d7, with d7 occupied by opposite color' do
        let(:d4) { board.board_db[:d4] }
        let(:d7) { board.board_db[:d7] }

        before do
          # setup test board
          board.pieces = {
            white:
            {
              r: [Rook.new(:white)]
            },
            black:
            {
              b: [Bishop.new(:black)]
            }
          }

          white_rook = board.pieces[:white][:r][0]
          black_bishop = board.pieces[:black][:b][0]

          board.place(white_rook, d4)
          board.place(black_bishop, d7)
        end
        it "replaces the piece of the target cell
          with the piece of the source cell" do
          d7 = board.board_db[:d7]
          expect { board.move_piece(d4, d7) }.to change { d7.piece.class }.to(Rook)
        end

        it 'removes the rook from d4' do
          expect { board.move_piece(d4, d7) }.to change { d4.piece }.to(nil)
        end
      end
    end

    context 'place' do; end

    context "when placing a piece along the line of a 
    multilinear piece" do
      let(:d4) { board.board_db[:d4] }
      let(:d7) { board.board_db[:d7] }
      let(:e7) { board.board_db[:e7] }

      before do
        board.place(Rook.new(:white), d4)
        board.place(Rook.new(:white), e7)
      end
      it 'shortens the valid moves of the multilinear piece' do
        remaining_moves = %i[f8 g7 h7 e8 e6 e5 e4 e3 e2 e1]
        expect { board.move_piece(d4, d7) }.to (
          change { e7.piece.moves }).to(remaining_moves)
      end
    end
  end

  describe '#place' do
    context 'when placing a white rook in h8' do
      it 'gives the rook the proper moves' do
        symbol_array = ->(arr) { arr.map { |i| i.join.to_sym } }
        white_rook = Rook.new(:white)
        h8 = board.board_db[:h8]

        move_group1 = symbol_array.call([*'a'..'g'].zip(Array.new(7, 8)).reverse)
        move_group2 = symbol_array.call(Array.new(7, 'h').zip([*1..7]).reverse)
        valid_moves = move_group1 + move_group2

        expect (board.place(white_rook, h8)).to change { h8.piece.moves }.to(valid_moves)
        puts 'place not changing connections'
      end
    end
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
  describe '#filter_connections' do
    let(:pawn) { Pawn.new(:white) }
    let(:black_piece) { Rook.new(:black) }
    let(:white_piece) { Bishop.new(:white) }
    let(:b7) { board.board_db[:b7] }
    let(:a8) { board.board_db[:a8] }
    let(:b8) { board.board_db[:b8] }
    let(:c8) { board.board_db[:c8] }


    before do
      board_db = board.board_db
      current_king = double('King', check_removers: [], check?: false)
      
      b7.piece = pawn
      a8.piece = white_piece
      c8.piece = black_piece

      b7.to_connections = [a8: a8, b8: b8, c8: c8]
      allow(b7).to receive(:not_skewed).and_return(true)
      allow(board).to receive(:king).with(:white).and_return(current_king)
    end
    it "returns an array of keys of the cells connected to b7 for which the
    piece can move to" do
      expect(board.filter_connections(b7)).to eq([:b8, :c8])
    end
  end
end