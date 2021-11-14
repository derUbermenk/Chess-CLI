# frozen_string_literal: true

require 'yaml'
require_relative 'game'
require_relative 'io/io'

# handles loading new and old games 
class Main
  include ChessIO

  def run
    main_instructions
    user_input = verify_input(input) { |input| %w[l n].include?(input) }
    game = case user_input
           when 'l' then load_game
           when 'n' then new_game
           end
    play(game)
  end

  # initiates player turns
  # @param game [Game]
  def play(game)
    game.play
  end

  def new_game
    Game.new
  end

  def load_game
    saves = retrieve_saves
    display_load_interface(saves)

    print 'enter index: '
    save_index = verify_input(gets.chomp.to_i, "save number must be in #{[*0...saves.size].join(' | ')}\nenter index: ") do |index|
      [*0...saves.size].include?(index.to_i)
    end
    YAML.load(File.read(saves[save_index]))
  end

  def retrieve_saves
    Dir['saves/*.yml']
  end
end

main = Main.new
main.run