# frozen_string_literal: true
require_relative '../lib/game'

describe Game do
  describe '#play' do
    # check internal methods
  end

  describe '#turn_order' do
    subject(:game) { described_class.new }
    it 'rotates player que and allow turn rotation' do; end
  end

  describe '#player_turn' do
    subject(:game) { described_class.new }

    context "when input is ss-save1" do
      before do
        allow_any_instance_of(Player).to receive(:move).and_return(true)
        allow(game).to receive(:get_input).and_return('ss-save1', 'k1-d1-d4')
        allow(game).to receive(:save_game)

      end
      it 'calls save game, then calls move' do
        expect(game).to receive(:save_game)
        game.player_turn
      end
    end
  end

  describe '#end_game?' do
    it 'checks if end game conditions have been met' do; end
  end

  describe '#end_cause' do
    it 'returns a message containing why the game ended' do; end
  end

  describe '#save' do
    subject(:game) { described_class.new }
    it 'saves the current state of a game' do; end
  end
end
