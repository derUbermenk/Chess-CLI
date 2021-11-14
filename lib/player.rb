# frozen_string_literal: true

require_relative 'board_elements/cell'
require_relative 'board_elements/piece'
require_relative '../lib/board'
require_relative 'io/io'

class Player
  include ChessIO

  attr_accessor :color
  attr_reader :symbol

  # @param color [String]
  # @param king [King]
  # @param board [Board] this is where moves are executed
  def initialize(color, king, board)
    @color = color
    @king = king
    @board = board
    @symbol = @color == :black ? "\u25cb" : "\u25cf"
  end

  # verifies and updates pieces if player_move is valid
  # @param player_move [String] the move command
  def move(input)
    loop do
      player_move = format_input(input)
      valid(player_move)
      return execute(player_move) if valid(player_move)

      input = verify_input('', 'invalid move, enter new move: ') do |player_input|
        player_input.match?(MOVE_SYNTAX)
      end
    end
  end

  # checks input validity
  # ... returns null if input is invalid
  # @param move [Hash] piece_key: in_cell: to_cell:
  def valid(move)
    piece = "#{move[:piece]}-#{move[:in_cell]}"
    to_cell = move[:to_cell]

    available_moves[piece]&.include?(to_cell) || false
  end

  # calls functions for updating cell states
  # @param move [Hash] consisting of keys piece_key, in_cell and to_cell 
  # @param [Hash] cell keys and correspoding cells
  def execute(move)
    in_cell = @board.board_db[move[:in_cell]]

    if %i[enpeasant_left enpeasant_right].include?(move[:to_cell])
      @board.enpeasant(in_cell, move[:to_cell]) 
    elsif move[:to_cell].to_s.match?(/^promote_[a-h](1|8)$/)
      @board.promote(in_cell, move[:to_cell])
    elsif %i[castle_left castle_right].include?(move[:to_cell])
      @board.castle(in_cell, move[:to_cell])
    else
      to_cell = @board.board_db[move[:to_cell]]
      @board.move_piece(in_cell, to_cell)
    end
  end

  # formats player move in to hash
  # ... with :piece_key, :in_cell, :to_cell
  # ... and symbol representations of the move input
  # @param input [String] <piece_key>-<in_cell>-<to_cell>
  # @return [Hash]
  def format_input(input)
    inputs = input.split('-')
    piece = inputs[0].to_sym
    in_cell = inputs[1].to_sym
    to_cell = inputs[2].to_sym

    { piece: piece, in_cell: in_cell, to_cell: to_cell }
  end

  def checkmate?
    @king.check && no_more_moves
  end

  def stalemate?
    !@king.check && no_more_moves
  end

  # queries for the available moves
  # for all remaining pieces
  def available_moves
    @board.valid_moves(@color)
  end

  private

  # checks if all remaining pieces
  # have no more moves
  def no_more_moves
    available_moves.values.all?(&:empty?)
  end
end
