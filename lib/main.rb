# frozen_string_literal: true

require 'yaml'
require_relative 'game'
require_relative 'chess_IO'

class Main
  include Chess_IO

  def run
    main_instructions
    user_input = verify_input(input) { |input| %w[l n].include?(input) }
    game = load_game if user_input == 'l'
    game = Game.new if user_input == 'n'

    game.play
  end

  def load_game
    saves = retrieve_saves
    display_load_interface(saves)

    save_index = input.to_i
    YAML.load(saves[save_index])
  end

  def retrieve_saves
    Dir['saves/*.yml']
  end
end
