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

    case king.check?
    when true
      # checks if there are no more valid moves
      @pieces.values.inject(true) do |emptyness, piece|
        emptyness and piece.valid_moves.empty
      end
    when false
      return false
    end
  end

  # a stalemate condition is reached when all of player's pieces #valid method
  # are empty
  def stalemate?
    @pieces.values.inject(true) do |emptyness, piece|
      emptyness and piece.valid_moves.empty
    end
  end

  private

  # converts an input to hash array
  # the input is assumed to be already valid
  # ... i.e. follows the move format since it has
  # ... passed the regex matches in Game
  # @param input [String] move input
  # @return [Hash] with key piece and to_position
  def format(input)
    info = input.split('-')
    { piece: info[0], to_position: info[1] }
  end
end
