# frozen_string_literal: true
require_relative 'board_elements/cell'
require_relative 'board_elements/piece'
require_relative '../lib/board'
require_relative 'io/io'

class Player
  include ChessIO

  # @param color [String]
  # @param king [King]
  # @param board [Board] this is where moves are executed
  def initialize(color, king, board)
    @color = color
    @king = king
    @board = board
  end

  # verifies and updates pieces if player_move is valid
  # @param player_move [String] the move command
  def move(input)
    loop do
      player_move = format_input(input)
      return execute(player_move) if valid(player_move)

      input = verify_input('', 'invalid move') do |player_input|
        player_input.match?(MOVE_SYNTAX)
      end
    end
  end

  # checks input validity
  # ... returns null if input is invalid
  # @param move [Hash] piece_key-in_cell: to_cell:
  def valid(move)
    piece = move[:piece]
    to_cell = move[:to_cell]

    allowed_moves = @board.valid_moves(@color)
    allowed_moves[piece]&.include?(to_cell) || false
  end

  # calls functions for updating cell states
  # @param player_move [Hash] consisting of keys piece_key, in_cell and to_cell 
  # @param board_db [Hash] cell keys and correspoding cells
  def execute(player_move, board_db)
    in_cell = board_db[player_move[:in_cell]]
    to_cell = board_db[player_move[:to_cell]]

    in_cell.move_piece_to(to_cell)
  end

  # formats player move in to hash
  # ... with :piece_key, :in_cell, :to_cell
  # ... and symbol representations of the move input
  # @param input [String] <piece_key>-<in_cell>-<to_cell>
  # @return [Hash]
  def format_input(input)
    inputs = input.split('-')
    piece = inputs[0..1].join('-')
    to_cell = inputs.last.to_sym

    { piece: piece, to_cell: to_cell }
  end
end
