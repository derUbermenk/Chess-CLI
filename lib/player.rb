# frozen_string_literal: true
require_relative '../lib/cells'
require_relative '../lib/pieces/king'
require_relative '../lib/chess_IO'

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
  # @param board [Hash] cell keys and corresponding cell objects 
  def move(input, board)
    loop do
      player_move = Hash[%i[piece_key in_cell to_cell].zip(input.split('-'))]

      return execute(player_move, board) if valid(player_move, board)

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
  # @param player_move [String] <piece_key>-<in_cell>-<to_cell>
  def valid(player_move, board_db)
    move_piece = player_move[:piece_key]
    cell_piece = board_db[player_move[:in_cell]].piece
    to_cell = player_move[:to_cell]

    valid_piece?(move_piece, cell_piece) && valid_cell?(cell_piece, to_cell) && (return player_move)
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

  def valid_piece?(move_piece, cell_piece)
    move_piece == cell_piece.key && color == cell_piece.color
  end

  def valid_cell?(cell_piece, to_cell)
    cell_piece.valid_moves.include?(to_cell)
  end
end
