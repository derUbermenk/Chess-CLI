# frozen_string_literal: true

require_relative '../lib/board'

describe Board do
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

  describe '#place' do
    let(:board) { Board.new(empty: true) }
    let(:db) { board.board_db }

    context 'when placing a piece in the path of a pre-existing multiline piece' do
      before do
        board.place(Rook.new(:black), db[:h1])
      end
      it 'cuts the path of the pre-existing multiline piece shorter' do
        white_pawn = Pawn.new(:white)
        expected_connections = [
          {
            h2: db[:h2],
            h3: db[:h3],
            h4: db[:h4],
            h5: db[:h5],
            h6: db[:h6],
            h7: db[:h7],
            h8: db[:h8]
          },
          {
            g1: db[:g1],
            f1: db[:f1]
          }
        ]
        expect { board.place(white_pawn, db[:f1]) }.to change{ db[:h1].to_connections }.to(expected_connections)
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
            k: [King.new(:white)],
            p: [Pawn.new(:white)]
          },
          black: {
            q: [Queen.new(:black)],
            r: [Rook.new(:black), Rook.new(:black)]
          }
        }

        board.place(board.pieces[:black][:q][0], db[:c4])
        board.place(board.pieces[:black][:r][0], db[:c3])
        board.place(board.pieces[:black][:r][1], db[:c5])

        board.place(board.pieces[:white][:k][0], db[:e4])
        board.place(board.pieces[:white][:p][0], db[:d4])
      end

      it 'returns empty moves for the skewed pieces' do
        expected_moves = { 'k-e4' => [:f4] , 'p-d4' => []}
        expect(board.valid_moves(:white)).to eq(expected_moves)
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
end
