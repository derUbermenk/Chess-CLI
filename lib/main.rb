# frozen_string_literal: true

require 'yaml'
require_relative 'game'
require_relative 'io/io'

class Main
  include ChessIO

  def run
    main_instructions
    user_input = verify_input(input) { |input| %w[l n].include?(input) }
    @game = case user_input
            when 'l' then load_game
            when 'n' then new_game
            end
    play
  end

  # initiates player turns
  # @param game [Game]
  def play
    @game.play
  end

  def new_game
    Game.new
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
