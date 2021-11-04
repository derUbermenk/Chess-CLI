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
    @coordinate = nil

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

  # checks if this self is in a given
  # ... collection of skewed positions
  def not_skewed; end

  def occupiable_by(color)
    return true if @piece.nil?

    return true if @piece.color != color
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