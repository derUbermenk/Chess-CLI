# frozen_string_literal: true

require_relative '../lib/board'

describe MappingTools do
  let(:board) { Board.new(empty: true) }

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
        expect_any_instance_of(Cell).to receive(:update_path).with(db[:d4], new_path)
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

  describe '#make_directions' do
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

end
