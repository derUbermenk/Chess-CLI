# frozen_string_literal: true

# cells make up boards. this allows movements of pieces
# in a board
class Cell
  attr_accessor :key, :square, :coordinate,
                :piece, :from_connections, :to_connections

  def initialize(key, square)
    @key = key
    @square = square
    @piece = nil
    @coordinate = []

    @from_connections = {}
    @to_connections = []
  end

  # removes the piece in self
  def remove_piece
    piece = @piece
    @piece = nil

    piece
  end

  # checks if the given cell is connected to self
  # via a to_connection.
  def connected?(cell)
    cell.from_connections.keys.include?(@key)
  end

  # update the path -- in to_connections containing the given cell
  # @param cell_key [Symbol] search for the path with the given cell key
  # @param new_path [Array] new array of path to replace said path
  def update_path(cell_key, new_path)
    @to_connections.map! do |path| 
      if path[cell_key]
        old_path = path

        old_path.size > new_path.size ? cut_path(old_path, new_path) : extend_path(old_path, new_path)
      else
        path
      end
    end
  end

  # returns a hash of the from connections containing a piece of the given color 
  def checking_cells(color)
    @from_connections.select { |cell_key, piece| piece.color == color }
  end

  # check if self has no from connections
  # containing a piece of the given color 
  # @param color [Symbol]
  def not_checked_by(color)
    @from_connections.values.all? do |piece| 
      piece.color != color
    end
  end

  def occupiable_by(color)
    @piece.nil? || @piece.color != color
  end

  # the piece of the cell or the square 
  # ... if no piece is available
  def show
    piece&.symbol || square
  end
end
