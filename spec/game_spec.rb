# frozen_string_literal: true

require_relative '../lib/game'

describe Game do
  describe '#play' do
    # check internal functions
  end

  describe '#turn_order' do
    it 'continues to call player turns until end game is reached' do
    end
  end

  describe '#end_game?' do
    context 'when there is a checkmate condition' do
      it 'ends turn order loop' do; end
    end
  end

  describe '#end_cause' do
    context 'when has winner' do
      it 'returns message with player name' do
      end
    end
  end
end
