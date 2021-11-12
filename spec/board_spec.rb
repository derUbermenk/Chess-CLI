# frozen_string_literal: true

require_relative '../lib/board'

describe Board do
  subject(:board) { described_class.new(empty: true) }
  let(:db) { board.board_db }
  describe '#initialize' do
    it 'calls place pieces when the board is initialized' do
      expect_any_instance_of(Board).to receive(:place_pieces)
      Board.new
    end

    context 'when initialized as empty' do
      it 'does not call create pieces' do
        expect_any_instance_of(Board).not_to receive(:place_pieces)
        Board.new(empty: true)
      end
    end
  end

  describe '#move_piece' do
    context "when placing a piece in a cell that causes a check to the king
      of opposite color" do
      before do
        white_king = King.new(:white)
        black_knigt = Knight.new(:black)
        board.pieces = {
          white: {
            k: [white_king]
          },
          black: {
            n: [black_knigt]
          }
        }

        board.place(white_king, db[:b6])
        board.place(black_knigt, db[:c5])
      end

      it 'changes the state of the opposites colors king to check = true' do
        expect { board.move_piece(db[:c5], db[:a4]) }.to change { db[:b6].piece.check }.to(true)
      end
    end
  end

  describe '#place' do
    let(:board) { Board.new(empty: true) }
    let(:db) { board.board_db }

    context "when placing a piece to the right in the path of a 
      pre-existing multiline piece" do
      before do
        board.place(Rook.new(:black), db[:h1])
      end
      it 'cuts the path of the pre-existing multiline piece shorter' do
        white_pawn = Pawn.new(:white)
        expected_connections = [
          { h2: nil, h3: nil, h4: nil, h5: nil, h6: nil, h7: nil, h8: nil },
          { g1: nil, f1: white_pawn }
        ]
        expect { board.place(white_pawn, db[:f1]) }.to change { db[:h1].to_connections }.to(expected_connections)
      end
    end

    context "when placing a piece to the left of the path of a 
      pre-existing multiline piece" do
      before do
        board.place(Queen.new(:black), db[:c4])
      end
      it 'cuts the path of the pre-existing multiline piece shorter' do
        white_pawn = Pawn.new(:white)
        expected_connections = [
          { d4: white_pawn },
          {
            d5: nil, e6: nil,
            f7: nil, g8: nil
          },
          {
            c5: nil, c6: nil,
            c7: nil, c8: nil
          },
          { b5: nil, a6: nil },
          { b4: nil, a4: nil },
          { b3: nil, a2: nil },
          { c3: nil, c2: nil, c1: nil },
          { d3: nil, e2: nil, f1: nil }
        ]
        expect { board.place(white_pawn, db[:d4]) }.to change { db[:c4].to_connections }.to(expected_connections)
      end
    end
  end

  describe '#show' do
    it 'shows an empty board' do
      board.show
    end

    context 'when showing a board with pieces' do
      it 'shows a new initialized board' do
        board = Board.new
        board.show
      end
    end

    context 'after moving a piece' do
      it 'updates the board to the updated positions' do
        board = Board.new
        db = board.board_db

        puts "\nunmoved state"
        board.show
        board.move_piece(db[:b2], db[:b4])
        board.move_piece(db[:d7], db[:d5])
        board.move_piece(db[:c1], db[:a3])

        puts "\nmoved state"
        board.show
      end
    end
  end

  describe '#valid_moves' do
    it "a hash of containing keys -- piece-in_cell and values 
      arrays of valid connections, given a piece color" do; end

    context 'when a piece is skewed it will not have any moves' do 
      let(:board) { Board.new(empty: true) }
      let(:db) { board.board_db }
      before do
        board.pieces = {
          white: {
            p: [Pawn.new(:white)],
            k: [King.new(:white)]
          },
          black: {
            k: [King.new(:black)],
            q: [Queen.new(:black)],
            r: [Rook.new(:black), Rook.new(:black)]
          }
        }

        board.place(board.pieces[:black][:k][0], db[:a4])
        board.place(board.pieces[:black][:q][0], db[:c4])
        board.place(board.pieces[:black][:r][0], db[:c3])
        board.place(board.pieces[:black][:r][1], db[:c5])

        board.place(board.pieces[:white][:k][0], db[:e4])
        board.place(board.pieces[:white][:p][0], db[:d4])
      end

      it 'returns empty moves for the skewed pieces' do
        expected_moves = { 'k-e4' => [:f4], 'p-d4' => [] }
        expect(board.valid_moves(:white)).to eq(expected_moves)
      end
    end

    context 'when calculating the valid moves for a full board' do
      it 'returns the valid moves' do
        board = Board.new
        p board.valid_moves(:white)
      end
    end
  end

  describe '#skewed' do
    # checks if the cell is skewed with the king(colored same with the piece in the cell)
    subject(:board) { described_class.new(empty: true) }
    let(:db) { board.board_db }

    context 'when the king and the cell in question are not in the same line' do
      before do
        db[:d4].piece=Rook.new(:white)
        db[:c7].piece=King.new(:white)


        db[:c7].piece.coordinate = db[:c7].coordinate
        allow(board).to receive(:king).with(:white).and_return(db[:c7].piece)
      end

      it 'returns false' do
        expect(board.skewed?(db[:d4])).to be false
      end
    end

    context "when the king and the cell in question is in the same line but the cell is
      in the endpoint of the line" do
      before do
        db[:h2].piece = Rook.new(:white)
        db[:d2].piece = King.new(:white)

        db[:h2].piece.coordinate = db[:h2].coordinate 
        allow(board).to receive(:king).with(:white).and_return(db[:h2].piece)
      end

      it 'returns false' do
        expect(board.skewed?(db[:h2])).to be false
      end
    end

    context 'when the king and the cell in question is skewed diagonally' do
      context 'when the skewing piece is a queen' do
        before do
          db[:a5].piece = King.new(:black)
          db[:c3].piece = Rook.new(:black)
          db[:e1].piece = Queen.new(:white)

          db[:a5].piece.coordinate = db[:a5].coordinate
          allow(board).to receive(:king).with(:black).and_return(db[:a5].piece)
        end

        it 'returns true' do
          expect(board.skewed?(db[:c3])).to be true
        end
      end

      context 'when the skewing piece is a bishop' do
        before do
          db[:a5].piece = Queen.new(:white)
          db[:c3].piece = Rook.new(:black)
          db[:e1].piece = King.new(:black)

          db[:e1].piece.coordinate = db[:e1].coordinate
          allow(board).to receive(:king).with(:black).and_return(db[:e1].piece)
        end

        it 'returns true' do
          expect(board.skewed?(db[:c3])).to be true
        end
      end
    end

    context 'when skewed horizontally' do
      before do
        db[:a2].piece = Queen.new(:white)
        db[:d2].piece = Rook.new(:black)
        db[:h2].piece = King.new(:black)

        db[:h2].piece.coordinate = db[:h2].coordinate
        allow(board).to receive(:king).with(:black).and_return(db[:h2].piece)
      end

      it 'returns true' do
        expect(board.skewed?(db[:d2])).to be true
      end
    end

    context 'when skewed vertically' do
      before do
        db[:a7].piece = King.new(:white)
        db[:a5].piece = Knight.new(:white)
        db[:a2].piece = Rook.new(:black)

        db[:a7].piece.coordinate = db[:a7].coordinate
        allow(board).to receive(:king).with(:white).and_return(db[:a7].piece)
      end

      it 'returns true' do
        expect(board.skewed?(db[:a5])).to be true
      end
    end
  end

  describe '#remove' do
    let(:board) { Board.new(empty: true) }
    let(:db) { board.board_db }
    let(:pawn_a3) { Pawn.new(:white) }
    let(:pawn_a4) { Pawn.new(:white) }
    let(:pawn_a5) { Pawn.new(:white) }
    context 'when removing the pawn in cell a4' do
      before do
        board.pieces = {
          white: {
            p: [pawn_a3, pawn_a4, pawn_a5]
          }
        }

        board.place(pawn_a3, db[:a3])
        board.place(pawn_a4, db[:a4])
        board.place(pawn_a5, db[:a5])
      end
      it 'removes that pawn in the database' do
        updated_board_pieces = {
          white: {
            p: [pawn_a3, pawn_a5]
          }
        }
        expect{ board.remove(pawn_a4) }.to change { board.pieces }.to(updated_board_pieces)
      end
    end
  end

  describe '#assess_check' do
    let(:white_king) { King.new(:white) }
    context 'when two pieces are checking the king' do
      before do
        board.place(white_king, db[:c4])
        board.place(Knight.new(:black), db[:e3])
        board.place(Bishop.new(:black), db[:g8])
      end
      it 'changes king.check count to 2' do
        expect { board.assess_check(:white) }.to change{ white_king.check_count }.to(2)
      end

      it 'sets changes the king.check_removers to []' do
        expect { board.assess_check(:white) }.to change { white_king.check_removers }.to([])
      end
    end

    context 'when one piece is checking the king' do
      context 'when that piece is a non multiline' do
        before do
          board.place(white_king, db[:c4])
          board.place(Knight.new(:black), db[:e3])
        end

        it 'returns an array containing the key of the checking piece' do
          expect { board.assess_check(:white) }.to change { white_king.check_removers }.to([:e3])
        end

        it 'sets changes the king.check_count to 1' do
          expect { board.assess_check(:white) }.to change{ white_king.check_count }.to(1)
        end
      end

      context 'when that piece is a multiline' do
        before do
          board.place(white_king, db[:c4])
          board.place(Bishop.new(:black), db[:g8])
        end

        it 'returns an array containing the key of the checking piece' do
          path_to_bishop = %i[d5 e6 f7 g8]
          expect { board.assess_check(:white) }.to change { white_king.check_removers }.to(path_to_bishop)
        end

        it 'sets changes the king.check_count to 1' do
          expect { board.assess_check(:white) }.to change{ white_king.check_count }.to(1)
        end
      end


    end
  end
end
