# frozen_string_literal: true
require_relative '../lib/Pieces'
require_relative '../lib/chess_IO'

class Player
  include Chess_IO

  def initialize
    @pieces = Pieces.new
  end

  def move(input)
    loop do
      player_move = valid(input)

      return @pieces.update(player_move) if player_move

      input = verify_input('', 'invalid move') do |input|
        input.match?(/^[kqnbrp][1-8]-[a-h][1-8]$/)
      end
    end
  end

  # a move is valid when it
  # ... is inside the posible move positions
  # ... will not result into a checked state of the king
  # ... removes a checked state of a king
  def valid(input)
    move = format(input)

    return move if @pieces[move[:piece]].valid_moves.include?(move[:to_position])

    nil
  end

  # checkmate is achieved if the players king, indexed by k1 is in check
  # ... and is no other moves are possible that can block the king
  def checkmate?
    king = @pieces['k1']

    return no_more_moves? if king.check?

    false
  end

  # a stalemate condition is reached when all of player's pieces #valid method
  # are empty
  def stalemate?
    no_more_moves?
  end

  private

  # converts an input to hash array
  # the input is assumed to be already valid
  # ... i.e. follows the move format since it has
  # ... passed the regex matches in Game
  # @param input [String] move input
  # @return [Hash] with key piece and to_position
  def format(input)
    move_information = input.split('-')
    { piece: move_information[0], to_position: move_information[1] }
  end

  # checks if there are no more moves available for player
  def no_more_moves?
    remaining_pieces = @pieces.values
    remaining_pieces.map(&:valid_moves).all?(&:empty?)
  end
end
