# frozen_string_literal: true

require_relative '../lib/board_elements'
require_relative '../lib/symbols'

# Parent Class of all chess pieces
class Piece
  attr_accessor :moves
  attr_reader :color, :symbol, :multiline

  include Symbol

  # initializes a piece. Multiline pieces are those that
  # ... can occupy either of the cells that are along a specific
  # ... linear direction (queens, bishops and rooks).
  # @param color [Symbol]
  # @param key [Symbol]
  # @param multiine [Boolean]
  def initialize(color, key, multiline)
    @moves = []

    @key = key 
    @color = color
    @symbol = set_symbol(@key, @color)
    # special for castling
    @multiline = multiline
  end

  # returns an array of directional coordinates -- itself an array
  # for which the piece is allowed to go, sans limitations
  # @param coordinates [Array] the coordinate of cell
  # ... that the piece is in
  # @return [Array]
  def scope(coordinates) 
    # draw lines
  end
end

# 
class King < Piece
  def initialize(color, key: :k, multiline: false)
    super
  end
end

#
class Queen < Piece
  def initialize(color, key: :q, multiline: true)
    super
  end
end

#
class Knight < Piece
  def initialize(color, key: :n, multiline: false)
    super
  end
end

#
class Bishop < Piece
  def initialize(color, key: :b, multiline: true)
    super
  end
end

#
class Rook < Piece
  def initialize(color, key: :r, multine: true)
    super
  end
end

#
class Pawn < Piece
  def initialize(color, key: :p, multiline: false)
    super
  end
end
