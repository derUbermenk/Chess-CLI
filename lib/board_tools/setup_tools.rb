# frozen_string_literal
require_relative '../board'
require_relative '../io/symbols'

module SetupInstructions
  include MappingTools
  include ChessSymbols

  def create_board_db
    columns = ('a'..'h').to_a
    rows = ('1'..'8').to_a
    board_db = {}

    squares = [BLACK_SQUARE, WHITE_SQUARE]
    rows.each do |row|
      columns.each do |column|
        cell_key = (column + row).to_sym
        board_db[cell_key] = Cell.new(cell_key, squares.first)
        squares.rotate!
      end
      squares.rotate!
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
end
