# frozen_string_literal: true 

require_relative '../lib/player'

describe Player do
  describe '#move' do
  end

  describe '#valid' do
    let(:board) { Board.new(empty: true) }
    let(:player1) { Player.new(:white, King.new(:white), board) }
    context 'when player is moving a valid piece but not to a valid cell' do
      before do
        allowed_moves = { 'q-d3' => %i[d5 d7 d8 a5], 'n-d4' => %i[d9 d10 d11] }
        allow(board).to receive(:valid_moves).with(:white).and_return(allowed_moves)
      end
      it 'returns false' do
        move = {piece: 'n-d4', to_cell: :a5}
        validity = player1.valid(move)
        expect(validity).to be false
      end
    end

    context 'when player is trying to move a absent piece' do
      before do
        allowed_moves = { 'q-d3' => %i[d5 d7 d8 a5], 'n-d4' => %i[d9 d10 d11] }
        allow(board).to receive(:valid_moves).with(:white).and_return(allowed_moves)
      end

      it 'returns false' do
        move = { piece: 'n-d3', to_cell: :a5 }
        validity = player1.valid(move)
        expect(validity).to be false
      end
    end

    context 'when player is trying to move a valid piece to a valid cell' do
      before do
        allowed_moves = { 'n-d3' => %i[d5 d7 d8 a5], 'n-d4' => %i[d9 d10 d11] }
        allow(board).to receive(:valid_moves).with(:white).and_return(allowed_moves)
      end

      it 'returns true' do
        move = { piece: 'n-d3', to_cell: :a5 }
        validity = player1.valid(move)
        expect(validity).to be true
      end
    end
  end
end
