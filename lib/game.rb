# frozen_string_literal: true

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
    player_input = gets.chomp
    save_game if player_input.match?(ss-<filename>)
    undo_game if player_input.mathc?(uz)
    
    current_player.move(player_input)
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
  def save_game 
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
end
