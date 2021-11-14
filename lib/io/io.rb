module ChessIO 
  SAVE_SYNTAX = /^ss-\w+$/
  UNDO_SYNTAX = /^uz$/
  MOVE_SYNTAX = /^[kqnbrp]-[a-h][1-8]-([a-h][1-8]|enpeasant_(left|right)|castle_(left|right)|promote_[a-h](1|8))$/

  def input
    gets.chomp
  end

  # returns input if input passes given block
  # which serves as condition for a valid format
  # @param input [String]
  def verify_input(input, message = 'invalid input | ')
    loop do
      return input if yield input

      print message
      input = gets.chomp
    end
  end

  def make_piece_prompt
    message = 'promote pawn to the ff: [Queen: q; Knight: n; Rook: r; Bishop: b]'
    puts message
    verify_input(gets.chomp, message) { |input| %i[q n r b].include?(input) }
  end

  def show_current_player(player)
    puts "\nCurrent Player: #{player.color} | #{player.symbol}"
    puts "\n"
  end

  # available moves is a hash
  def show_available_moves(available_moves)
    available_moves.reject! { |cell_key, moves| moves.empty? }

    available_moves.each_with_index do |(cell_key, moves), indx|
      print "#{cell_key}: #{moves.join(' | ')} || " if indx.even?
      puts "#{cell_key}: #{moves.join(' | ')} \n" if indx.odd?
    end

    puts "\n"
  end

  def get_player_input
    print 'enter move: '
    gets.chomp
  end

  def display_line_bottom
    puts "---------------------------------------------------\n"
  end

  def display_line_top
    puts "\n---------------------------------------------------"
  end

  # prints the checkmate message
  # @param winner [Player]
  def checkmate_message(winner)
    puts "Checkmate! #{winner.color} | #{winner.symbol} wins"
  end

  def stalemate_message
    puts 'Stalemate! Draw'
  end

  def instructions_message
    puts 'Input instructions'
  end

  def invalid_input_message
    puts 'Invalid input'
  end

  def invalid_move_message
    puts 'invalid move'
  end

  # main methods

  # displays a load interface for choosing
  # ... which save to load
  # @param save_list [Array]
  def main_instructions
    puts "load game[l]\nnew game[n]"
  end
  def display_load_interface(save_list)
    formatted_save_list = list_formatter(save_list) do |save_name, index| 
      "[#{index}] - #{save_name.match(%r{^saves/(\w+).yml$})[1]}"
    end
    puts formatted_save_list.join("\n")
  end

  def list_formatter(list)
    list.each_with_object([]).with_index do |(element, formatted_collection), index|
      formatted_collection << yield(element, index)
    end
  end
end
