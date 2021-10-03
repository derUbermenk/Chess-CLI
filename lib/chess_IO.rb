module Chess_IO 
  def input
    gets.chomp
  end

  # returns input if input passes given block
  # which serves as condition for a valid format
  # @param input [String]
  def verify_input(input)
    loop do
     return input if yield input
     
     puts 'invalid input'
    end
  end

  # prints the checkmate message
  # @param winner [Player]
  def checkmate_message(winner)
    puts "Checkmate! #{winner.name} wins"
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
