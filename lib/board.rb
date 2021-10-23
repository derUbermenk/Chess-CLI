# frozen_string_literal: true
require_relative '../lib/cell'
require_relative '../lib/symbols'
require_relative '../lib/board_elements/*'

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

    set_pieces unless empty
  end

  # @param in_cell [Cell]
  # @param to_cell [Cell]
  def move_piece(in_cell, to_cell)
    piece = in_cell.piece.pop
    place(piece, to_cell)

    removal_remap(in_cell)
  end

  # places the piece in given cell
  # @param in_cell [Cell]
  def place(piece, in_cell)
    capture_piece(in_cell) unless in_cell.piece.empty?
    in_cell.piece << piece

    placement_remap(in_cell)
  end

  # removes the piece in a cell
  # @param in_cell [Cell]
  def capture_piece(in_cell)
    piece = in_cell.piece.pop

    # then delete piece in piece database
    @pieces[piece.color][piece.key].pop
  end

  # remaps all connections in a context of piece removal
  # @param cell [Cell]
  def removal_remap(cell)
    # delete references in from_connections of other cells
    disconnect(cell.to_connections)

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
  end
 
  # recreates a path passing through a cell this could remove/add 
  # ... references to a cell in @to_connections
  # @param cell [Cell]
  def remap_paths_passing_through(cell)
    cell.from_connections.each_value do |connection|
      map_path_passing_through(connection, cell) if connection.piece[0].multiline
    end
  end

  def map_to_connections(cell)
    # scope would be an array of coordinates grouped by direction
    # ... i.e. [[[0,0], [0,1]], [[0,2], [1,3]]]
    # ... where for each pair, first is row, last is column
    scope = piece.scope(cell.coordinate)

    # convert the directional array coordinates into
    # ... directional array of connections, connections are hashes
    # ... with cell_key: cell
    cell.to_connections = scope.map do |direction|

      # cells referred to by all the coordinates in direction
      cells_in_direction = direction.map do |coordinate| 
        board_cartesian[coordinate[0]][coordinate[1]]
      end

      # given all the cells in that direction
      # get the list of cells up to the first non empty cell
      cells_in_direction.find.with_object([]) do |cell_in_path, clear_path|
        clear_path << cell_in_path
        !cell_in_path.piece.empty?
      end
    end
  end


  # edits the connection in cell containing to_cell
  # ... this is used in cases where cell.piece is a multicell
  # ... linear piece; bishops queens and the like, when the piece
  # ... in to_cell has been removed
  # ... clearly in such cases, the connections containing to_cell
  # ... will change.
  def map_path_passing_through(cell1, cell2)
    # find the hash containing to_cell.key then remap that connection
    cell1.to_connections.find.with_index do |connection, index|
      next unless connection.keys.include?(cell2.key)

      # a list of cells passing to the given points
      coord_path = path_from(cell1.coordinates, cell2.coordinates)

      # then find all get all cells up to the first non_empty cell
      cell1[index] = clear_path(coord_path)
    end
  end

  # returns a color's piece
  # @param color [Symbol] the color of the king to be returned
  # @return king [King]
  def king(color)
    pieces[color][:k][0]
  end

  # check if there are no more moves for all pieces of given color
  # @param color [String]
  def stalemate?(color)

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
        cell_key = column.concat(row).to_sym
        board_db[cell_key] = Cell.new(cell_key, square.first)
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
        cell.coordinate = [row, column]
        cell
      end
    end
  end

  def create_pieces
    {
      white:
      {
        k: [King.new],
        q: [Queen.new],
        n: Array.new(2, Knight.new),
        b: Array.new(2, Bishop.new),
        r: Array.new(2, Rook.new),
        p: Array.new(8, Pawn.new)
      },
      black:
      {
        k: [King.new],
        q: [Queen.new],
        n: Array.new(2, Knight.new),
        b: Array.new(2, Bishop.new),
        r: Array.new(2, Rook.new),
        p: Array.new(8, Pawn.new)
      }
    }
  end

  def set_pieces
    set_white_piece
    set_black_piece
  end

  # sets the black pieces in the board
  def set_white_piece 
    pieces = @pieces[:white]

    @board_db[:e1].place(pieces[:k])
    @board_db[:d1].place(pieces[:q])
    set_multiple_pieces([@board_db[:a1], @board_db[:h1]], pieces[:r])
    set_multiple_pieces([@board_db[:b1], @board_db[:g1]], pieces[:n])
    set_multiple_pieces([@board_db[:c1], @board_db[:f1]], pieces[:b])
    set_multiple_pieces(@board_cartesian[1], pieces[:p])
  end

  # sets the white pieces in the board
  def set_black_piece
    pieces = @pieces[:black]

    @board_db[:e8].place(pieces[:k])
    @board_db[:d8].place(pieces[:q])
    set_multiple_pieces([@board_db[:a8], @board_db[:h8]], pieces[:r])
    set_multiple_pieces([@board_db[:b8], @board_db[:g8]], pieces[:n])
    set_multiple_pieces([@board_db[:c8], @board_db[:f8]], pieces[:b])
    set_multiple_pieces(@board_cartesian[6], pieces[:p])
  end

  # use this for setting more than one pieces
  # @param cell_collection [Array] the cells where the pieces are to be placed
  # @param pieces [Array] the pieces to place in the cell collections 
  def set_multiple_pieces(cell_collections, pieces)
    cell_collections.zip(pieces).each do |cell, piece|
      cell.place(piece)
    end
  end
end