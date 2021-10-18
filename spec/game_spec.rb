# frozen_string_literal: true

require_relative '../lib/main'

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
    let(:valid_move_format) { 'p-d4-d5' }
    let(:valid_save_format) { 'ss-saveGame1' }
    let(:invalid_move_format) { 'rr2-d7-d8' }

    context 'when input is follows proper_save_format then a proper move format' do
      before do
        allow_any_instance_of(Player).to receive(:move).and_return(true)
        allow(game).to receive(:input).and_return(valid_save_format, valid_move_format)
        allow(game).to receive(:save).with(valid_save_format)
      end

      it 'calls save game, then calls move' do
        expect(game).to receive(:save).with(valid_save_format)
        expect_any_instance_of(Player).to receive(:move).with(valid_move_format).and_return(valid_move_format)
        game.player_turn
      end
    end

    context 'when input is proper move format, and assuming the move is valid' do
      before do
        allow(game).to receive(:input).and_return(valid_move_format)
        allow_any_instance_of(Player).to receive(:move).and_return(valid_move_format)
      end

      it 'makes current player call move and the proper move input' do
        expect_any_instance_of(Player).to receive(:move).with(valid_move_format).once
        expect(game).to_not receive(:invalid_input_message)
        expect(game).to_not receive(:instructions_message)

        game.player_turn
      end
    end

    context 'when an improper format is entered as input twice and the proper input is made once' do
      before do
        allow(game).to receive(:input).and_return(invalid_move_format, invalid_move_format,valid_move_format)
        allow_any_instance_of(Player).to receive(:move).and_return(valid_move_format)
      end
      it 'reports the invalid input and instruction twice and then allows the input' do
        expect_any_instance_of(Player).to receive(:move).with(valid_move_format).once
        expect(game).to receive(:invalid_input_message).twice
        expect(game).to receive(:instructions_message).twice
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
    let(:valid_save_format) { 'ss-validName' }

    context 'when save directory exists' do
      before do
        allow(Dir).to receive(:mkdir)
        allow(File).to receive(:open)
      end

      it 'checks if save directory is present, and returns true' do
        expect(Dir).to receive(:exist?).and_return(true)
        game.save(valid_save_format)
      end

      it 'sends a message to save file to yaml' do
        save_path = 'saves/validName.yml'
        expect(File).to receive(:open).with(save_path, 'w')
        game.save(valid_save_format)
      end

      it 'prints the filename of the savefile with a message' do
        message = "Save successful: #{valid_save_format.split('-').last}"

        expect(game).to receive(:puts).with(message)
        game.save(valid_save_format)
      end
    end
  end
end
