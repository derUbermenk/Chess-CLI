# frozen_string_literal: true

require_relative '../lib/board'

describe MappingTools do
  let(:board) { Board.new(empty: true) }
  let(:db) { board.board_db }

  describe '#placement_remap' do
    # test the ff functions
    #   1. remap_paths_to(cell)
    #   2. remap_paths_from(cell)
    #   3. filter_connections(cell)
    it 'calls the necessary functions' do
      cell = board.board_db[:a7]

      expect(board).to receive(:map_paths_to).with(cell)
      expect(board).to receive(:map_paths_from).with(cell)

      board.placement_remap(cell)
    end
  end

  describe '#removal_remap' do
    it 'calls the necessary functions' do
      cell = board.board_db[:a7]

      expect(board).to receive(:map_paths_to).with(cell)
      expect(cell).to receive(:disconnect)
      board.removal_remap(cell)
    end
  end

  describe '#map_paths_to' do
    let(:board) { Board.new(empty: true) }
    let(:db) { board.board_db }

    context "when the cell has a from connection from a multiline piece and a
      piece is placed in it" do
      before do
        db[:d2].piece = Rook.new(:white)
        board.map_paths_from(db[:d2])
        db[:d4].piece = Knight.new(:black)
      end

      it 'makes the connection call update direction with piece' do
        new_path = { d4: db[:d4], d3: db[:d3] }
        expect_any_instance_of(Cell).to receive(:update_path).with(:d4, new_path)
        board.map_paths_to(db[:d4])
      end
    end
  end

  describe '#map_paths_from' do
    let(:black_rook) { Rook.new(:black) }
    let(:black_pawn) { Pawn.new(:black) }
    let(:white_pawn) { Pawn.new(:white)}
    let(:db) { board.board_db }
    let(:d4) { db[:d4] }

    context "when a black rook is placed in d4, a white pawn is in g4 and a black pawn
      in d6" do
      before do
        # setup board
        g4 = db[:g4]
        d6 = db[:d6]

        d4.piece = black_rook 
        g4.piece = white_pawn
        d6.piece = black_pawn
      end

      it "changes the self.to_connections to an array of cell hash containing {e4..g4},
        {d5}, {c4..a4}, and {d3..d1}" do
        connections = [
          { e4: db[:e4], f4: db[:f4], g4: db[:g4] },
          { d5: db[:d5], d6: db[:d6] },
          { c4: db[:c4], b4: db[:b4], a4: db[:a4] },
          { d3: db[:d3], d2: db[:d2], d1: db[:d1] }
        ]

        expect { board.map_paths_from(d4) }.to change{ d4.to_connections }.to(connections)
      end

      it "adds cell references to the from connections of all the cells it has 
        to_connections to" do
        connections = {
          e4: db[:e4], f4: db[:f4], g4: db[:g4], d5: db[:d5],
          c4: db[:c4], b4: db[:b4], a4: db[:a4], d3: db[:d3],
          d2: db[:d2], d1: db[:d1]
        }

        board.map_paths_from(d4)

        connections.each_value do |connection|
          d4_query = connection.from_connections[:d4]
          expect(d4_query).to eq(d4)
        end
      end
    end
  end

  describe '#filter_connections' do
    let(:board) { Board.new(empty: true) }
    let(:db) { board.board_db }
    it 'returns an array of cell keys where the given cell can move to' do; end

    context 'given a white knight in c4' do
      context 'when the king is not in check, and all to connections are occupiable' do
        before do
          king_coordinate = db[:e4].coordinate
          current_king = double('King', coordinate: king_coordinate, check: false)
          white_knight = Knight.new(:white)
          black_pawn = Pawn.new(:black)

          board.place(white_knight, db[:c4])
          board.place(black_pawn, db[:b6])

          allow(board).to receive(:king).with(:white).and_return(current_king)
        end

        it 'returns the cell keys that are occupiable by the color of the piece in self' do
          expected_valid_connections = %i[e5 d6 b6 a5 a3 b2 d2 e3]
          calculated_valid_connections = board.filter_connections(db[:c4])
          expect(calculated_valid_connections).to eq(expected_valid_connections)
        end
      end
    end
  end

  describe '#filter_connections_king' do
    let(:board) { Board.new(empty: true) }
    let(:db) { board.board_db }

    context 'when some of the to connections have from connections from cells with pieces of opposite color' do
      before do
        black_king = King.new(:black)
        white_rook1 = Rook.new(:white)
        white_rook2 = Rook.new(:white)

        board.place(black_king, db[:c4])
        board.place(white_rook1, db[:b5])
        board.place(white_rook2, db[:b3])

        allow(board).to receive(:king).with(:black).and_return(black_king)
      end

      it 'returns the cell keys of all to connections except does that are checked' do
        expected_valid_connections = %i[d4]
        calculated_valid_connections = board.filter_connections_king(db[:c4])

        expect(calculated_valid_connections).to eq(expected_valid_connections)
      end
    end

    context 'when two pieces remain and the other is skewed' do
      let(:board) { Board.new(empty: true) }
      let(:db) { board.board_db }
      before do
        <<-doc
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
        doc

        black_queen = Queen.new(:black)
        black_rook1 = Rook.new(:black)
        black_rook2 = Rook.new(:black)

        white_king = King.new(:white)
        white_pawn = Pawn.new(:white)

        <<-doc
        board.place(board.pieces[:black][:q][0], db[:c4])
        board.place(board.pieces[:black][:r][0], db[:c3])
        board.place(board.pieces[:black][:r][1], db[:c5])

        board.place(board.pieces[:white][:k][0], db[:e4])
        board.place(board.pieces[:white][:p][0], db[:d4])
        doc

        board.place(black_queen, db[:c4])
        board.place(black_rook1, db[:c3])
        board.place(black_rook2, db[:c5])

        board.place(white_king, db[:e4])
        board.place(white_pawn, db[:d4])
      end

      it 'returns available moves for the non skewed pieces' do
        expected_valid_connections = [:f4]
        calculated_valid_connections = board.filter_connections_king(db[:e4])
        #expect(calculated_valid_connections).to eq(expected_valid_connections)
      end
    end
  end

  # helpers

  describe '#make_directions' do
    context 'when given the points [7,6] [7,6]' do
      it 'returns an empty direction' do
        calculated_direction = board.make_direction([7, 6], [7, 6])
        expect(calculated_direction).to eq([])
      end
    end
    context 'when given the points [2,3] [1,2]' do
      it "returns the collections of coordinates along the line from start_point through
        through_point" do
        point1 = [2, 3]
        point2 = [1, 2]
        calculated_direction = board.make_direction(point1, point2)
        expected_direction = [[1,2],[0,1]]
        expect(calculated_direction).to eq(expected_direction)
      end
    end

    context 'when given the points [2,4], [4,2]' do
      it "returns the collections of coordinates along the line from start_point through
        through_point" do
        point1 = [2, 4]
        point2 = [5, 1]

        calculated_direction = board.make_direction(point1, point2)
        expected_direction = [[3, 3], [4, 2], [5, 1], [6, 0]]
        expect(calculated_direction).to eq(expected_direction)
      end
    end

    context 'when given the points [4, 5] and [2, 7]' do
      it "returns the collections of coordinates along the line from start_point through
        through point" do
        point1 = [4, 5]
        point2 = [2, 7]

        calculated_direction = board.make_direction(point1, point2)
        expected_direction = [[3, 6], [2, 7]]
        expect(calculated_direction).to eq(expected_direction)
      end
    end

    context 'when given the points [2, 7] and [4, 5]' do
      it "returns the collections of coordinates along the line from start_point through
        through point" do
        point1 = [2, 7]
        point2 = [4, 5]

        calculated_direction = board.make_direction(point1, point2)
        expected_direction = [[3, 6], [4, 5], [5, 4], [6, 3], [7, 2]]
        expect(calculated_direction).to eq(expected_direction)
      end
    end

    context 'when given the points [4, 5]  and [4, 7]' do
      it "returns the collections of coordinates along the line from start_point through
        through point" do
        point1 = [4, 5]
        point2 = [4, 7]

        calculated_direction = board.make_direction(point1, point2)
        expected_direction = [[4, 6], [4, 7]]
        expect(calculated_direction).to eq(expected_direction)
      end
    end

    context 'when given the points [3, 4] and [2, 4]' do
      it "returns the collections of coordinates along the line from start_point through
        through point" do
        point1 = [3, 4]
        point2 = [2, 4]

        calculated_direction = board.make_direction(point1, point2)
        expected_direction = [[2, 4], [1, 4], [0, 4]]
        expect(calculated_direction).to eq(expected_direction)
      end
    end
  end

  describe '#get_path' do
    context 'when given a direction' do 
      before do
        db[:a5].piece = Pawn.new(:white)
      end
      it 'returns the list of all cells up to the first non empty cell' do
        direction = board.make_direction([0,1], [0, 7])
        correct_path = board.convert_to_cells([[0, 2], [0, 3], [0, 4]]).map(&:key)
        path = board.get_path(direction).keys
        expect(path).to eq(correct_path)
      end
    end
  end
end
