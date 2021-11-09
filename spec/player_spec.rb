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
        move = {piece: :n, in_cell: :d4, to_cell: :a5}
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
        move = { piece: :n, in_cell: :d3, to_cell: :a5 }
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
        move = { piece: :n, in_cell: :d3, to_cell: :a5 }
        validity = player1.valid(move)
        expect(validity).to be true
      end
    end
  end

  describe '#checkmate?' do
    let(:player1) { Player.new(:white, King.new(:white), Board.new(empty: true)) }
    context 'when there are no more moves remaining' do
      context 'and the king is in check' do
        before do
          valid_moves = {'k-d3': [], 'n-d1': [], 'p-h6': []}
          allow_any_instance_of(Board).to receive(:valid_moves).with(:white).and_return(valid_moves)
          allow_any_instance_of(King).to receive(:check).and_return(true)
        end
        it 'returns true' do
          expect(player1.checkmate?).to be true
        end
      end

      context 'and the king is not in check' do
        before do
          valid_moves = {'k-d3': [], 'n-d1': [], 'p-h6': []}
          allow_any_instance_of(Board).to receive(:valid_moves).with(:white).and_return(valid_moves)
          allow_any_instance_of(King).to receive(:check).and_return(false)
        end
        it 'returns false' do
          expect(player1.checkmate?).to be false
        end
      end
    end

    context 'when there are still moves remaining' do
      before do
        valid_moves = {'k-d3': %i[d5 d7], 'n-d1': [], 'p-h6': []}
        allow_any_instance_of(Board).to receive(:valid_moves).with(:white).and_return(valid_moves)
        allow_any_instance_of(King).to receive(:check).and_return(false)
      end

      it 'returns false' do
        expect(player1.checkmate?).to be false
      end
    end
  end

  describe '#stalemate?' do
    let(:player1) { Player.new(:white, King.new(:white), Board.new(empty: true)) }
    context 'when ther are no more moves remaining' do
      context 'and the king is in check' do
        before do
          valid_moves = {'k-d3': [], 'n-d1': [], 'p-h6': []}
          allow_any_instance_of(Board).to receive(:valid_moves).with(:white).and_return(valid_moves)
          allow_any_instance_of(King).to receive(:check).and_return(true)
        end
        it 'returns true' do
          expect(player1.stalemate?).to be false 
        end
    end

      context 'and the king is not in check' do
        before do
          valid_moves = {'k-d3': [], 'n-d1': [], 'p-h6': []}
          allow_any_instance_of(Board).to receive(:valid_moves).with(:white).and_return(valid_moves)
          allow_any_instance_of(King).to receive(:check).and_return(false)
        end
        it 'returns true' do
          expect(player1.stalemate?).to be true 
        end
      end
    end

    context 'when there are still moves remaining' do
      before do
        valid_moves = {'k-d3': %i[d5 d7], 'n-d1': [], 'p-h6': []}
        allow_any_instance_of(Board).to receive(:valid_moves).with(:white).and_return(valid_moves)
        allow_any_instance_of(King).to receive(:check).and_return(false)
      end

      it 'returns false' do
        expect(player1.stalemate?).to be false
      end
    end
  end

end
