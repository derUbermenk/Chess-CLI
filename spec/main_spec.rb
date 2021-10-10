# frozen_string_literal: true

require_relative '../lib/main'

describe Main do
  subject(:main) { described_class.new }

  describe '#run' do
    context 'when player chooses to load game' do
      before do
        old_game = Game.new
        allow(main).to receive(:main_instructions)
        allow(main).to receive(:verify_input).and_return('l')
        allow(main).to receive(:load_game).and_return(old_game)
        allow_any_instance_of(Game).to receive(:play)
      end

      it 'loads a pre-existing game' do
        expect(main).to receive(:load_game)
        expect_any_instance_of(Game).to_not receive(:initialize)
        expect_any_instance_of(Game).to receive(:play)
        main.run
      end
    end

    context 'when player chooses to have a new game' do
      before do
        allow(main).to receive(:main_instructions)
        allow(main).to receive(:verify_input).and_return('n')
        allow_any_instance_of(Game).to receive(:play)
      end

      it 'initializes a new game' do
        expect(main).to_not receive(:load_game)
        expect_any_instance_of(Game).to receive(:initialize)
        expect_any_instance_of(Game).to receive(:play)
        main.run
      end
    end
  end

  describe '#load_game' do
    let(:save_path) { ['saves/save1.yml'] }
    it 'loads a saved game' do; end

    context 'when user chooses a save game named save1' do
      before do
        allow(YAML).to receive(:load)

        allow(main).to receive(:retrieve_saves).and_return(save_path)
        allow(main).to receive(:display_load_interface)
        allow(main).to receive(:input).and_return('0')
      end
      it 'makes YAML send a load message with the file path as input' do
        expect(YAML).to receive(:load).with(save_path.first)
        main.load_game
      end
    end
  end

  describe '#retrieve_saves' do
    it 'returns a list of all files in saves folder' do; end
  end

  # from chess_io module
  describe '#display_load_interface' do
    let(:save_list) { ['saves/save1.yml', 'saves/save2.yml'] }

    it 'displays a load interface for choosing which save game to load' do; end

    context 'when there are to save files' do
      it 'returns outputs the expected puts argument' do
        expected_puts_argument = "[0] - save1\n[1] - save2"

        expect(main).to receive(:puts).with(expected_puts_argument)
        main.display_load_interface(save_list)
      end
    end
  end

  # from chess_io module
  describe '#list_formatter' do
    let(:save_list) { ['saves/save1.yml', 'saves/save2.yml'] }

    it 'returns a formatted array based on the formatting block given' do; end

    context 'when formatting block is "<index> - <element_name>"' do
      it 'returns an array with "<index>-<element_name>" elements as per given input' do
        expected_list = ['[0] - save1', '[1] - save2']

        formatted_list = main.list_formatter(save_list) do |save_name, index|
          "[#{index}] - #{save_name.match(%r{^saves/(\w+).yml$})[1]}"
        end

        expect(formatted_list).to eql(expected_list)
      end
    end
  end
end
