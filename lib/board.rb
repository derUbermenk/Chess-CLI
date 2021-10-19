# frozen_string_literal: true
require_relative '../lib/cell'

# allows cell to cell interactions
# parameters:
#   @pieces: collection of black pieces
#   @board_db: hash with cell_keys as keys and cell as values
#   @board_cartesian: array with [0][0] as cell a1 [7][7] as h8
class Board
  attr_accessor :board_cartesian, :@board_db, :@pieces

  # set up initial board state
  def initialize
    @board_db = create_board_db
    @board_cartesian = create_board_cartesian
    @pieces = create_pieces

    set_pieces
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
    pieces = pieces[color.to_sym].values.flatten
    moves = pieces.map(&:valid_moves)

    moves.all?(&:empty?)
  end

  # outputs the board in the cli
  def show
    ordered_rows = @board_cartesian.reverse.map(&:contents.first.symbol)
    formatted_rows = ordered_rows.map { |row| " #{row.join('|')} " }

    puts formatted_rows.join("\n")
  end

  private

  def create_board_db
    columns = ('a'..'h').to_a
    rows = ('1'..'8').to_a

    board_db = {}

    rows.each do |row|
      columns.each do |column|
        cell_name = column.concat(row)
        board_db[cell_name] = Cell.new(self, cell_name)
      end
    end
  end

  def create_board_cartesian
    cells = @board_db.values

    Array.new(8) { cells.slice!(0..7)}
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