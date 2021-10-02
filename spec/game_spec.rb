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

  describe '#end_game?' do
    it 'checks if end game conditions have been met' do; end
  end

  describe '#end_cause' do
    it 'returns a message containing why the game ended' do; end
  end

  describe '#save' do
    it 'saves the current state of a game' do; end
  end
end