# frozen_string_literal: true 

require_relative '../lib/player'

describe Player do
  describe '#move' do
  end

  describe '#valid' do
    let(:player1) { Player.new(:white, King.new(:white)) }
    context 'when player is moving a valid piece but not to a valid cell' do
      it 'returns false' do
        # validity = allowed_moves[piece] && allowed_moves[piece].include?(to_cell)
        move = {piece: 'n-d4', to_cell: :a5}
        allowed_moves = {'q-d3' => %i[d5 d7 d8 a5], 'n-d4' => %i[d9 d10 d11]}
        validity = player1.valid(move, allowed_moves)
        expect(validity).to be false
      end
    end

    context 'when player is trying to move a absent piece' do
      it 'returns false' do
        # validity = allowed_moves[piece] && allowed_moves[piece].include?(to_cell)
        move = { piece: 'n-d3', to_cell: :a5 }
        allowed_moves = {'q-d3' => %i[d5 d7 d8 a5], 'n-d4' => %i[d9 d10 d11]}
        validity = player1.valid(move, allowed_moves)
        expect(validity).to be false
      end
    end

    context 'when player is trying to move a valid piece to a valid cell' do
      it 'returns true' do
        move = { piece: 'n-d3', to_cell: :a5 }
        allowed_moves = { 'n-d3' => %i[d5 d7 d8 a5], 'n-d4' => %i[d9 d10 d11] }
        validity = player1.valid(move, allowed_moves)
        expect(validity).to be true
      end
    end
  end
end
