# frozen_string_literal: true
require_relative 'board_elements/cell'
require_relative 'board_elements/piece'
require_relative 'io/io'

class Player
  include ChessIO

  # @param color [String]
  # @param king [King]
  def initialize(color, king)
    @color = color
    @king = king
  end

  # verifies and updates pieces if player_move is valid
  # @param player_move [String] the move command
  # @param board_db [Hash] cell keys and corresponding cell objects 
  def move(input, board_db)
    loop do
      player_move = format_input(input)
      return execute(player_move, board_db) if valid(player_move, board_db)

      input = verify_input('', 'invalid move') do |player_input|
        player_input.match?(MOVE_SYNTAX)
      end
    end
  end

  def checkmate?
    king.checkmate?
  end

  # checks input validity
  # ... returns null if input is invalid
  # @param player_move [Hash] piece_key: in_cell: to_cell:
  def valid(player_move, board_db)
    in_cell = board_db[player_move[:in_cell].to_sym]
    to_cell = board_db[player_move[:to_cell].to_sym]

    piece_key = player_move[:piece_key]
    in_cell_piece = in_cell.piece

    not_skewed = !@king.skewed_positions.include?(in_cell.key)
    correct_piece = valid_piece?(piece_key, in_cell_piece)
    correct_cell = valid_cell?(in_cell, to_cell)

    valid_move = not_skewed && correct_piece && correct_cell

    return valid_move && removes_check(to_cell) if @king.check?

    valid_move
  end

  # calls functions for updating cell states
  # @param player_move [Hash] consisting of keys piece_key, in_cell and to_cell 
  # @param board_db [Hash] cell keys and correspoding cells
  def execute(player_move, board_db)
    in_cell = board_db[player_move[:in_cell]]
    to_cell = board_db[player_move[:to_cell]]

    in_cell.move_piece_to(to_cell)
  end

  private

  # checks if to_cell is in positions which can remove a check
  # @param to_cell [Symbol]
  def removes_check?(to_cell)
    @king.check_removers.include?(to_cell)
  end

  # checks if the cell being accessed by player move contains
  # ... a piece being referenced by the move and that the piece
  # ... is of the same color
  # @param piece_key [Symbol] the player input piece key 
  # @param in_cell_piece [Cell] the piece that is in in_cell
  # @return [TrueClass, FalseClass]
  def valid_piece?(piece_key, in_cell_piece)
    same_key = in_cell_piece.key == piece_key
    same_color = in_cell_piece.color == @color

    return true if same_key && same_color
  end

  # checks if the in_cell and to_cell are connected
  # and if to_cell contains a piece of opposite color
  # @param in_cell [Cell]
  # @param to_cell [Cell]
  def valid_cell?(in_cell, to_cell)
    connected = in_cell.to_connections[to_cell.key]
    capturing_opposite_color = to_cell.piece.color != @color

    return true if connected && capturing_opposite_color
  end

  # formats player move in to hash
  # ... with :piece_key, :in_cell, :to_cell
  # ... and symbol representations of the move input
  # @param input [String] <piece_key>-<in_cell>-<to_cell>
  # @return [Hash]
  def format_input(input)
    inputs = input.split('-').map(&:to_sym)
    Hash[%i[piece_key in_cell to_cell].zip(inputs)]
  end
end
