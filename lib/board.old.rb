# frozen_string_literal: true
require_relative '../lib/io/symbols'
require_relative '../lib/board_elements/cell'
require_relative '../lib/board_elements/piece'

# allows cell to cell interactions
# parameters:
#   @pieces: collection of black pieces
#   @board_db: hash with cell_keys as keys and cell as values
#   @board_cartesian: array with [0][0] as cell a1 [7][7] as h8
class Board
  attr_accessor :board_cartesian, :board_db, :pieces

  include ChessSymbols

  # set up initial board state
  def initialize(empty: false)
    @board_db = create_board_db
    @board_cartesian = create_board_cartesian
    @pieces = create_pieces

    place_pieces unless empty
  end

  # @param in_cell [Cell]
  # @param to_cell [Cell]
  def move_piece(in_cell, to_cell)
    piece = in_cell.remove_piece
    place(piece, to_cell)

    removal_remap(in_cell)
  end

  # places the piece in given cell
  # @param in_cell [Cell]
  def place(piece, in_cell)
    capture_piece(in_cell) unless in_cell.piece.nil?
    in_cell.piece = piece

    placement_remap(in_cell)
  end

  # removes the piece in a cell
  # @param in_cell [Cell]
  def capture_piece(in_cell)
    piece = in_cell.remove_piece

    # then delete piece in piece database
    @pieces[piece.color].delete(piece.key)
  end

  # remaps all connections in a context of piece removal
  # @param cell [Cell]
  def removal_remap(cell)
    # delete references to cell in from_connections of other cells
    disconnect(cell)

    # recalculate the paths of all cells in self.from_connections passing
    # ... through cell
    remap_paths_passing_through(cell)

    # empty the two connections
    cell.to_connections = []
  end

  # remaps the connections of a cell given the context
  # ... that a piece has been placed
  # @param cell [Cell]
  def placement_remap(cell)
    # remap all paths passing through cell
    remap_paths_passing_through(cell)

    # point cells to other cells
    map_to_connections(cell)

    # filter the valid connections for piece in cell
    cell.piece.moves = filter_connections(cell)
  end

  # removes references to cell in the from connections of 
  # ... other cells
  # @param cell [Cell]
  def disconnect(cell)
    connections = cell.to_connections.map(&:values).flatten

    connections.each do |to_cell|
      to_cell.from_connections.delete(cell.key)
    end
  end

  # recreates a path passing through a cell this could remove/add 
  # ... references to a cell in @to_connections
  # @param cell [Cell]
  def remap_paths_passing_through(cell)
    cell.from_connections.each_value do |from_cell| 
      map_path_passing_through(from_cell, cell) if from_cell.piece.multiline

      # then recalculate the possible moves for the piece in the from_cell 
      from_cell.piece.moves = filter_connections(from_cell)
    end
  end

  def map_to_connections(cell)
    piece = cell.piece
    # where a direction is a hash with cell_key: cell
    # ... along a line of some direction
    piece.scope(cell.coordinate).map do |direction|

      # convert directional coordinates to cells
      direction = direction.map do |coordinate|
        x, y = coordinate[0], coordinate[1]
        @board_cartesian[x][y]
      end
      get_path(direction)
    end
  end

  # edits the connection in cell1 containing cell2
  # ... this is used in cases where cell.piece is a multicell
  # ... linear piece; bishops queens and the like, when the piece
  # ... in to_cell has been removed
  # ... clearly in such cases, the connections containing to_cell
  # ... will change.
  def map_path_passing_through(cell1, cell2)
    # find the hash containing to_cell.key then remap that connection
    cell1.to_connections.find.with_index do |connection, index|
      next unless connection.keys.include?(cell2.key)

      coord_path = path_from(cell1.coordinates, cell2.coordinates)

      # then edit the direction where cell2 is located
      cell1[index] = get_path(coord_path)
    end
  end

  # returns a Hash containing the nearest cell to cell
  # ... up to the first non-empty cell
  # @param direction [Array] array of coordinates following a direction 
  # @return [Hash] cell_key: Cell
  def get_path(direction)
    direction.find.with_object({}) do |cell, path|
      path[cell.key] = cell

      # stop iteration when cell contains a piece
      # ... positioning allows us to still add that cell
      !cell.piece.nil?
    end
  end

  # filters the possible moves given the piece in a cell 
  # @param of_cell [Cell]
  def filter_connections(of_cell)
    of_cell_connections = of_cell.to_connections.map(&:values).flatten

    # filter out cells that do not allow in_cells piece to move to
    valid_connections = of_cell_connections.select do |cell|
      valid_connection?(of_cell, cell)
    end

    # then returns the keys of the cells
    valid_connections.map(&:key)
  end

  # returns a color's piece
  # @param color [Symbol] the color of the king to be returned
  # @return king [King]
  def king(color)
    pieces[color][:k][0]
  end

  # check if there are no more moves for all pieces of given color
  # @param color [Symbol]
  def stalemate?(color)
    pieces_remaining = @piece[color].values.flatten

    # find returns nil if no moves remaining
    pieces_remaining.find { |piece| !piece.moves.empty? }.nil?
  end

  # outputs the board in the cli
  def show
    ordered_rows = @board_cartesian.reverse.map(&:contents)
    formatted_rows = ordered_rows.map { |row| " #{row.join('|')} " }

    puts formatted_rows.join("\n")
  end

  private

  # creates a hash with actual cell objects
  # @return board_db [Hash] with :cell_key and Cell object
  def create_board_db
    columns = ('a'..'h').to_a
    rows = ('1'..'8').to_a
    board_db = {}

    squares = [BLACK_SQUARE, WHITE_SQUARE]
    rows.each do |row|
      columns.each do |column|
        cell_key = (column + row).to_sym
        board_db[cell_key] = Cell.new(cell_key, squares.first)
        squares.rotate
      end
      squares.rotate
    end

    board_db
  end

  def create_board_cartesian
    cells = @board_db.values

    Array.new(8) do |row|
      cells.slice!(0..7).each_with_index do |cell, column|
        cell.coordinate = [column, row]
        cell
      end
    end
  end

  def create_pieces
    {
      white:
      {
        k: [King.new(:white)],
        q: [Queen.new(:white)],
        n: Array.new(2, Knight.new(:white)),
        b: Array.new(2, Bishop.new(:white)),
        r: Array.new(2, Rook.new(:white)),
        p: Array.new(8, Pawn.new(:white))
      },
      black:
      {
        k: [King.new(:black)],
        q: [Queen.new(:black)],
        n: Array.new(2, Knight.new(:black)),
        b: Array.new(2, Bishop.new(:black)),
        r: Array.new(2, Rook.new(:black)),
        p: Array.new(8, Pawn.new(:black))
      }
    }
  end

  def place_pieces 
    place_black_pieces 
    place_white_pieces
  end

  def place_white_pieces 
    white_pieces = @pieces[:white]

    place_multiple([@board_db[:e1]], white_pieces[:k])
    place_multiple([@board_db[:d1]], white_pieces[:q])
    place_multiple([@board_db[:a1], @board_db[:h1]], white_pieces[:r])
    place_multiple([@board_db[:b1], @board_db[:g1]], white_pieces[:n])
    place_multiple([@board_db[:c1], @board_db[:f1]], white_pieces[:b])
    place_multiple(@board_cartesian[1], white_pieces[:p])
  end

  def place_black_pieces
    black_pieces = @pieces[:black]

    place_multiple([@board_db[:e8]], black_pieces[:k])
    place_multiple([@board_db[:d8]], black_pieces[:q])
    place_multiple([@board_db[:a8], @board_db[:h8]], black_pieces[:r])
    place_multiple([@board_db[:b8], @board_db[:g8]], black_pieces[:n])
    place_multiple([@board_db[:c8], @board_db[:f8]], black_pieces[:b])
    place_multiple(@board_cartesian[6], black_pieces[:p])
  end

  # place a collection of pieces of the same type and color in
  # ... a specified array of cells
  # @param cell_collections [Array]
  # @param pieces [Array]
  def place_multiple(cell_collections, pieces)
    cell_collections.zip(pieces).each do |cell, piece|
      place(piece, cell)
    end
  end

  # returns an array of points starting but excluding point1
  # ... passing through point2 up to the bounds of the
  # ... board, marked by the lines x = 7, y = 7 
  # @param point1 [Array] containing x1, y2
  # @param point2 [Array] containing x2, y2
  def path_from(point1, point2)
    x1, y1 = point1[0], point1[1]
    x2, y2 = point2[0], point2[1]

    slope = (y2 - y1) / (x2 - x1).to_f
    y_intercept = y2 - (slope * x2)
    y = ->(x) { (slope * x) + y_intercept }

    x_values = [*0..7]

    path = x_values.each_with_object([]) do |x, path|
      y_val = y.call(x)
      path << [x, y_val.to_i] if x_values.include?(y_val)
    end

    # do not include point 1
    path[1..-1]
  end

  # returns checks if a connection between two cells
  # ... are valid
  # Validity allows the piece in cell 1 to be moved
  # ... to cell 2
  # @param cell1 the cell where the piece originates
  # @param cell2 the cell where the piece is moving to
  # return [TrueClass, FalseClass]
  def valid_connection?(cell1, cell2)
    moving_color = cell1.piece.color
    current_king = king(moving_color)
    check_removers = current_king.check_removers
    cell2_empty = cell2.piece.nil?
    validity = cell1.not_skewed && cell2.occupiable_by(moving_color)

    return validity && check_removers.include?(cell2.key) if current_king.check?

    validity
  end
end
