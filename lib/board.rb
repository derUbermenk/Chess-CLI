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
  attr_reader :king_cells, :cell_connector

  include ChessSymbols
  include MappingTools
  include SetupInstructions

  # set up initial board state
  def initialize(empty: false)
    @board_db = create_board_db
    @board_cartesian = create_board_cartesian
    @pieces = create_pieces
    @king_cells = {} # keeps track of the cell containing king
    @cell_connector = CellConnector.new(@board_db)

    place_pieces unless empty
  end

  # @param in_cell [Cell]
  # @param to_cell [Cell]
  def move_piece(in_cell, to_cell)
    piece = in_cell.remove_piece
    moving_color = piece.color
    waiting_color = opposite_color(moving_color)

    place(piece, to_cell)
    removal_remap(in_cell)

    assess_check(waiting_color) unless @king_cells[waiting_color].not_checked_by(moving_color)
  end

  # places the piece in given cell
  # @param in_cell [Cell]
  # @param piece [Piece]
  def place(piece, in_cell)
    @king_cells[piece.color] = in_cell if piece.instance_of?(King) 

    capture_piece(in_cell) unless in_cell.piece.nil?
    in_cell.piece = piece
    in_cell.piece.coordinate = in_cell.coordinate

    placement_remap(in_cell)
  end

  # removes the piece in a cell
  # @param in_cell [Cell]
  def capture_piece(in_cell)
    piece = in_cell.remove_piece

    remove(piece)
  end

  # returns a color's piece
  # @param color [Symbol] the color of the king to be returned
  # @return king [King]
  def king(color)
    pieces[color][:k][0]
  end

  # outputs the board in the cli
  def show
    formatted_rows = format_rows(row_contents)
    puts formatted_rows.join("\n")
  end

  # returns a hash of all cells containing
  # piece color and their valid connections
  def valid_moves(color)
    remaining_pieces = @pieces[color]
    remaining_pieces.each_with_object({}) do |(piece_key, pieces_), piece_moves|
      pieces_.each do |piece|
        cell = equiv_cell(piece.coordinate)
        piece_id = "#{piece_key}-#{cell.key}"
        piece_moves[piece_id] = piece.instance_of?(King) ? filter_connections_king(cell) : filter_connections(cell)
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
      path1 = get_path(make_direction(cell.coordinate, cell.coordinate.map{ |coord| coord-1 }))
      path2 = get_path(make_direction(cell.coordinate, cell.coordinate.map{ |coord| coord+1 }))
    when -1
      path1 = get_path(make_direction(cell.coordinate, [cell.coordinate[0]-1,  cell.coordinate[1] + 1]))
      path2 = get_path(make_direction(cell.coordinate, [cell.coordinate[0]+1, cell.coordinate[1] - 1]))
    end

    # not skewed when either of the paths are empty, maybe piece is at edge
    return false if path1.empty? || path2.empty?

    check_opposite_end = lambda do |opposite|
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
      false
    end
  end

  # gets the opposite color of the given color
  # @param color [Symbol]
  def opposite_color(color)
    color == :white ? :black : :white
  end

  # removes a piece in board db
  # @param piece [Piece]
  def remove(piece)
    color = piece.color
    piece_key = piece.key
    coordinate = piece.coordinate

    # pieces are identified from other pieces by their coordinate
    # and we delete the piece in the piece database via its index
    # to find its index in the piece data we search for the index of the piece
    # in the database with the coordinate == to that of the given piece, which 
    # is in fact the piece itself
    piece_index = @pieces[color][piece_key].index { |piece_| piece_.coordinate == coordinate}

    # then we delete the piece in the database
    @pieces[color][piece_key].delete_at(piece_index)
  end

  def assess_check(color)
    # * king refers to the king of the given color
    king_cell = @king_cells[color]
    checking_cells = king_cell.checking_cells(opposite_color(color))
    king = @king_cells[color].piece
    king.check_count = checking_cells.size
    king.check = true

    if king.check_count > 1
      # only way to remove checks when more than one check is to move the king
      # to an unchecked position
      king.check_removers = []
    elsif king.check_count == 1
      checking_cell_key = checking_cells.keys[0]
      checking_piece = checking_cells.values[0]
      check_cell_coordinate = checking_piece.coordinate

      king.check_removers = if checking_piece.multiline
                              get_path(make_direction(king_cell.coordinate,
                                                      check_cell_coordinate)).map(&:keys)
                            else
                              king.check_removers = [checking_cell_key]
                            end
    end
  end

  private  

  def format_rows(rows)
    rows = rows.reverse
    row_indxs = [*0..9].reverse
    normal_row = ->(indx) { "#{indx} | #{rows[indx].join(' | ')} | #{indx}" }
    column_row = ->(indx) { "    #{rows[indx].join('   ')}    " }

    row_indxs.each_with_object([]) do |indx, row_arr|
      formatted_row = [0, 9].include?(indx) ? column_row.call(indx) : normal_row.call(indx)
      row_arr << formatted_row
    end
  end

  # extract cell contents from all rows in the board_cartesian
  # ... and organizes the contents by rows.
  def row_contents
    contents = @board_cartesian.reverse.map do |row|
      row.map(&:show)
    end

    column_indexes = [*'a'..'h']
    contents.unshift(column_indexes)
    contents.append(column_indexes)
  end
end
