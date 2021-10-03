# frozen_string_literal: true

require_relative 'board'
require_relative 'player'
# Contains all logic for playing a chess game, connects all
# ... serves as interface for all relevant chess objects to
# ... interact with each other
class Game
  def initialize
    @player1 = Player.new
    @player2 = Player.new
    @board = Board.new

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
      player_input = get_input
      save_game if player_input.match?(/^ss-\w+$/)
      undo_game if player_input.match?(/^uz$/)
    
      # current player's move will have its own method for checking validity of move
      return current_player.move(player_input) if player_input.match?(/^[kqnbrp][12]-[a-h][1-8]-[a-h][1-8]$/)

      report_invalid_input
      report_instructions
    end
  end

  # checks if an end game condition has been met
  def end_game
    current_player.checkmate? || current_player.stalemate?
  end

  # checks if an end_cause has been done
  def end_cause
    if current_player.checkmate?
      checkmate_message(@player_que.last)
    elsif current_player.stalemate?
      stalemate_message
    end
  end

  private
  # saves a game
  def save_game; end

  # use this method for getting input
  def get_input
    gets.chomp
  end

  # not implemented yet
  def undo_move; end

  def current_player
    @player_que.first
  end

  def checkmate_message(winner)
    "Checkmate! #{winner.name} wins"
  end

  def stalemate_message
    'Stalemate! Draw'
  end

  def report_instructions
    puts 'instructions'
  end

  def report_invalid_input
    puts 'invalid input'
  end
end
