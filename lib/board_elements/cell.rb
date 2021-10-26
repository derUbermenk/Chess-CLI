# frozen_string_literal: true

# cells make up boards. this allows movements of pieces
# in a board
class Cell
  attr_accessor :cell_key, :square, :coordinate

  def initialize(cell_key, square)
    @cell_key = cell_key
    @square = square
    @coordinate = nil
  end
end