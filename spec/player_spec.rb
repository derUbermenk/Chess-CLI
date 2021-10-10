# frozen_string_literal: true 

require_relative '../lib/player'

describe Player do
  describe '#move' do
    it "updates a chosen piece's position" do; end
  end

  describe '#valid' do
    it 'returns the player_move hash if the move is valid' do; end
    it 'returns the nil if the move is not valid' do; end
  end

  describe '#checkmate?' do
    it 'checks if players king is in checkmate' do; end

  end

  describe '#stalemate' do
    it 'checks if players king is in stalemate' do; end
  end
end
