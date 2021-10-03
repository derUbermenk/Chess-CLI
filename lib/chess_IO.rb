module Chess_IO 
  def input
    gets.chomp
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

  # displays a load interface for choosing
  # ... which save to load
  # @param save_list [Array]
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
