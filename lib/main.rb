# frozen_string_literal: true

require 'yaml'
require_relative 'game'
require_relative 'chess_IO'

class Main
  include Chess_IO

  def run; end

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
