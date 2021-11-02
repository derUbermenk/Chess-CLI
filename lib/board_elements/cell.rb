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
  # deletes the reference to self in the from connection of 
  # a given cell
  # @param cell [Cell]
  def delete_ref(cell)
    cell.from_connections.delete(@key)
  end

end