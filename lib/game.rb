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
    @player1 = Player.new(:white, @board.king(:white), @board)
    @player2 = Player.new(:black, @board.king(:black), @board)

    @player_que = [@player1, @player2]
  end

  def play
    show_board
    turn_order until end_game

    end_cause
  end

  # switches between player to allow for moves
  def turn_order
    player_turn
    show_board

    rotate_players
  end

  # gets input for player with regards to saving and
  # moves. matches input to save game or undo move inputs
  # else assumes that player entered move input
  def player_turn
    loop do
      puts @board.valid_moves(current_player.color)
      print 'enter move: '
      player_input = gets.chomp 

      <<-doc
      if save_or_undo(player_input) 
        save(player_input) if player_input.match?(SAVE_SYNTAX)
        undo_game if player_input.match?(UNDO_SYNTAX)

        # then get a new input
        player_input = input 
      end
      doc

      return player_move(player_input) if player_input.match?(MOVE_SYNTAX)

      invalid_input_message
      instructions_message
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

  def save(input)
    Dir.mkdir('saves') unless Dir.exist?('saves')

    save_name = input.split('-').last
    File.open("saves/#{save_name}.yml", 'w') { |file| file.write(self.to_yaml) }

    puts "Save successful: #{save_name}"
  end

  # not implemented yet
  def undo_move; end

  private

  def show_board
    @board.show
  end

  def rotate_players
    @player_que.rotate!
  end

  def player_move(input)
    current_player.move(input)
  end

  def save_or_undo(input)
    input.match?(SAVE_SYNTAX) || input.match?(MOVE_SYNTAX)
  end

  def current_player
    @player_que.first
  end
end
