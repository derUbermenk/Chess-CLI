# frozen_string_literal: true

require_relative '../lib/board_elements'
require_relative '../lib/symbols'

# Parent Class of all chess pieces
class Piece
  attr_accessor :moves
  attr_reader :color, :symbol, :multiline

  include Symbol

  # @param color [Symbol]
  def initialize(color, key, multiline)
    @moves = []

    @key = key 
    @color = color
    @symbol = set_symbol(@key, @color)
    # special for castling
    @multiline = multiline
  end
end

class King < Piece
  attr_accessor :moves
  attr_reader :color, :symbol, :multiline

  include Symbol

  # @param color [Symbol]
  def initialize(color, key: :k, multiline: true)
    super
  end
end
