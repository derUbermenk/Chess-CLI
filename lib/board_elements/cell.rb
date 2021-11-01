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
end