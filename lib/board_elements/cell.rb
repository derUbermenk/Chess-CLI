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

  # add all connections to to_connections
  # and add refs to self to all connections
  def connect(connections)
    @to_connections = connections.each do |direction|
      direction.each { |key, cell| add_ref(cell)}
    end
  end

  def disconnect
    to_connections = @to_connections.map(&:values).flatten
    to_connections.each { |cell| delete_ref(cell) }

    @to_connections = []
  end

  # update the path -- in to_connections containing the given cell
  # @param cell [Cell] search for the path with the given cell
  # @param new_path [Array] new array of path to replace said path
  def update_path(cell_key, new_path)
    @to_connections.map! do |path| 
     if path[cell_key]
      new_path
     else
      path
     end
    end
  end

  # check if self has no from connections
  # containing a piece of the given color 
  # @param color [Symbol]
  def not_checked_by(color)
    @from_connections.values.all? do |cell| 
      cell.piece.color != color
    end
  end

  def occupiable_by(color)
    @piece.nil? || @piece.color != color
  end

  # the piece of the cell or the square 
  # ... if no piece is available
  def show
    piece || square
  end

  private

  # adds a self reference to cell.from_connections
  # @param cell [Cell]
  def add_ref(cell)
    cell.from_connections[@key] = self
  end

  # deletes the reference to self in the from connection of 
  # a given cell
  # @param cell [Cell]
  def delete_ref(cell)
    cell.from_connections.delete(@key)
  end

end