# frozen_string_literal: true
require_relative '../lib/Pieces'
require_relative '../lib/chess_IO'

class Player
  include Chess_IO

  def initialize(color)
    @pieces = Pieces.new(color)
  end

  # verifies and updates pieces if player_move is valid
  def move(input)
    loop do
      player_move = valid(input)

      return @pieces.update(player_move) if player_move

      input = verify_input('', 'invalid move') do |input|
        input.match?(/^[kqnbrp]-[a-h][1-8]-[a-h][1-8]$/)
      end
    end
  end
end
