# frozen_string_literal: true
require_relative '../lib/io/symbols'
require_relative '../lib/board_elements/cell'
require_relative '../lib/board_elements/piece'
require_relative '../lib/board_tools/mapping_tools'
require_relative '../lib/board_tools/setup_tools'

# allows cell to cell interactions
# parameters:
#   @pieces: collection of black pieces
#   @board_db: hash with cell_keys as keys and cell as values
#   @board_cartesian: array with [0][0] as cell a1 [7][7] as h8
class Board
  attr_accessor :board_cartesian, :board_db, :pieces

  include ChessSymbols
  include MappingTools
  include SetupInstructions

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
    in_cell.piece.coordinate = in_cell.coordinate 

    placement_remap(in_cell)
  end

  # removes the piece in a cell
  # @param in_cell [Cell]
  def capture_piece(in_cell)
    piece = in_cell.remove_piece

    board.remove(piece)
  end

  # returns a color's piece
  # @param color [Symbol] the color of the king to be returned
  # @return king [King]
  def king(color)
    pieces[color][:k][0]
  end

  # outputs the board in the cli
  def show
    ordered_rows = @board_cartesian.reverse.map(&:contents)
    formatted_rows = ordered_rows.map { |row| " #{row.join('|')} " }

    puts formatted_rows.join("\n")
  end

  # returns a hash of all cells containing piece color and their valid
  # .... connections
  # ... this will require the pieces to record their coordinates
  def valid_moves(color)
    # get the cells containing piece of given color
    # if king is in check
      # get check removers :: cells that can remove check
      # check removers are the only allowable moves
      # then filter connections for each cell
      # such that cell is not skewed and connection is in check re-
      # movers
    # otherwise if king is not in check
    # for each cell filter the to connections by the ff
    # cell must not be skewed -- empty otherwise
    # to_connection must not contain same color

    # return a hash with <piece-in_cell>: moves

    pieces = @pieces[:white]

    pieces.each_with_object({}) do |(piece_key, pieces), piece_moves|
      pieces.each do |piece|
        cell = to_cell(piece.coordinate)
        piece_key = "#{piece_key}-#{cell}".to_i
        piece_move = filter_connections(cell)

        piece_moves[piece_key] = piece_move
      end
    end
  end

  # checks if given cell is skewed
  # @param cell [Cell]
  def skewed?(cell)
    current_king = king(cell.piece.color)
    slope = LinearEquation.new(cell.coordinate, current_king.coordinate).slope

    # to be skewed the king and the cell in question must first be aligned
    # ... the two are aligned -- by the limits of the board if the lines connecting
    # ... them have the slopes [nil, 0, -1, 1] -- vertical, horizontal, diagonal

    return false unless [nil, 0, -1, 1].include?(slope) 

    case slope
    when nil
      path1 = get_path(make_direction(cell.coordinate, [cell.coordinate[0], 0]))
      path2 = get_path(make_direction(cell.coordinate, [cell.coordinate[0], 7]))
    when 0
      path1 = get_path(make_direction(cell.coordinate, [0, cell.coordinate[1]]))
      path2 = get_path(make_direction(cell.coordinate, [7, cell.coordinate[1]]))
    when 1
      path1 = get_path(make_direction(cell.coordinate, [cell.coordinate.map{ |coord| coord-1 }]))
      path2 = get_path(make_direction(cell.coordinate, [cell.coordinate.map{ |coord| coord+1 }]))
    when -1
      path1 = get_path(make_direction(cell.coordinate, [cell.coordinate[0]-1,  cell.coordinate[1] + 1]))
      path2 = get_path(make_direction(cell.coordinate, [cell.coordinate[0]+1, cell.coordinate[1] - 1]))
    end

    check_opposite_end = ->(opposite) do
      return false if opposite.empty?

      return false if opposite.values.last&.piece&.color == current_king.color

      return [Rook, Queen].include?(opposite.values.last&.piece.class) if [nil, 0].include?(slope)
      return [Bishop, Queen].include?(opposite.values.last&.piece.class) if [-1, 1].include?(slope)
    end

    if path1.values.last.piece == current_king
      check_opposite_end.call(path2)
    elsif path2.values.last.piece == current_king
      check_opposite_end.call(path1)
    else
      return false
    end
  end
end
