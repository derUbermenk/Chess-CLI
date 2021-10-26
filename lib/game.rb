# frozen_string_literal: true

require_relative 'io/io'
require_relative 'board'
require_relative 'player'
# Contains all logic for playing a chess game, connects all
# ... serves as interface for all relevant chess objects to
# ... interact with each other
class Game
  include ChessIO

  def initialize
    @board = Board.new
    @player1 = Player.new('white', board.king(:white))
    @player2 = Player.new('black', board.king(:black))

    @player_que = [@player1, @player2]
  end

  def play
    turn_order until end_game

    end_cause
  end

  # switches between player to allow for moves
  def turn_order
    player_turn
    @board.show

    @player_que.rotate!
  end

  # gets input for player with regards to saving and
  # moves. matches input to save game or undo move inputs
  # else assumes that player entered move input
  def player_turn
    loop do
      player_input = input
      save player_input if player_input.match?(SAVE_SYNTAX)
      undo_game if player_input.match?(UNDO_SYNTAX)

      return current_player.move(player_input) if player_input.match?(MOVE_SYNTAX)

      invalid_input_message
      instructions_message
    end
  end

  # checks if an end game condition has been met
  def end_game
    current_player.checkmate? || stalemate?
  end

  # checks if an end_cause has been done
  def end_cause
    if current_player.checkmate?
      checkmate_message(@player_que.last)
    elsif stalemate?
      stalemate_message
    end
  end

  def save(input)
    Dir.mkdir('saves') unless Dir.exist?('saves')

    save_name = input.split('-').last
    File.open("saves/#{save_name}.yml", 'w') { |file| file.write(self.to_yaml) }

    puts "Save successful: #{save_name}"
  end

  # not implemented yet
  def undo_move; end

  # a stalemate is reached when the current players pieces have no more available moves
  def stalemate?
    board.stalemate?(current_player.color)
  end

  private

  def player_move(input)
    current_player.move(input)
  end

  def current_player
    @player_que.first
  end
end
