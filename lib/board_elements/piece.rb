# frozen_string_literal: true

require_relative '../io/symbols'

# Parent Class of all chess pieces
class Piece
  attr_accessor :moves
  attr_reader :color, :symbol, :multiline

  include ChessSymbols

  # initializes a piece. Multiline pieces are those that
  # ... can occupy either of the cells that are along a specific
  # ... linear direction (queens, bishops and rooks).
  # @param color [Symbol]
  # @param key [Symbol]
  # @param multiine [Boolean]
  def initialize(color, key:, multiline:)
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

  private
  
  # calculates horizontal and vertical lines from coordinate
  def line_wise_directions(coordinate)
    x = coordinate[0]
    y = coordinate[1]

    [[*(x + 1)..7].zip(Array.new(7 - x, y)),
     Array.new(7 - y, x).zip([*(y+1)..7]),
     [*0..(x - 1)].reverse.zip(Array.new(x, y)),
     Array.new(y, x).zip([*0..(y - 1)].reverse)].reject(&:empty?)

  end

  # calculates all diagonal lines from coordinate 
  def diagonal_wise_directions(coordinate)
    x = coordinate[0]
    [draw_diagonal(coordinate, 1, [*(x + 1)..7]),
     draw_diagonal(coordinate, -1, [*0...x].reverse),
     draw_diagonal(coordinate, 1, [*0...x].reverse),
     draw_diagonal(coordinate, -1, [*(x + 1)..7])].reject(&:empty?)
  end

  # returns the array of coodinates passing through
  # coordinate
  # @param slope [Integer] the slope of the line for which the
  # ... the coordinates will be acquired
  # @param x_vals [Array] the Array of x_vals to calculate y 
  def draw_diagonal(coordinate, slope, x_vals)
    x_base = coordinate[0]
    y_base = coordinate[1]

    y_intercept = y_base - (slope * x_base)
    y_fn = ->(x) { (slope * x) + y_intercept }

    allowed_range = 0..7

    x_vals.each_with_object([]) do |x, path|
      y_val = y_fn.call(x)
      path << [x, y_val] if allowed_range.include?(y_val)
    end
  end

  # for non multiline pieces, selects only the 
  # ... directions where a coordinate is not out 
  # ... of bounds
  # @param scope [Array]
  def filter(scope)
    scope.reject do |direction|
      direction.flatten.all? { |xy| xy >= 0 && xy <= 7 }
    end
  end
end


class King < Piece
  def initialize(color, key: :k, multiline: false)
    super
  end

  def scope(coordinate)
    x = coordinate[0]
    y = coordinate[1]
    [
      [[x + 1, y]], [[x + 1, y + 1]],
      [[x - 1, y + 1]], [[x - 1, y]],
      [[x - 1, y - 1]], [[x, y - 1]],
      [[x + 1, y - 1]]
    ]
  end
end

#
class Queen < Piece
  def initialize(color, key: :q, multiline: true)
    super
  end

  def scope(coordinate)
    linewise = line_wise_directions(coordinate)
    diagonal_wise = diagonal_wise_directions(coordinate)

    linewise.zip(diagonal_wise).flatten(1).compact
  end
end

#
class Knight < Piece
  def initialize(color, key: :n, multiline: false)
    super
  end

  def scope(coordinates)
    x = coordinates.first
    y = coordinates.last

    quadrant1_x1 = x + 2
    quadrant1_x2 = x + 1
    quadrant2_x1 = x - 1
    quadrant2_x2 = x - 2

    # following quadrants with assumption of origin at
    # ... coordinate
    filter(
      [
        [[quadrant1_x1, y + 1]], [[quadrant1_x2, y + 2]],
        [[quadrant2_x1, y + 2]], [[quadrant2_x2, y + 1]],
        [[quadrant2_x2, y - 1]], [[quadrant2_x1, y - 2]],
        [[quadrant1_x2, y - 2]], [[quadrant1_x1, y - 1]]
      ]
    ) 
  end
end

#
class Bishop < Piece
  def initialize(color, key: :b, multiline: true)
    super
  end

  def scope(coordinate)
    diagonal_wise_directions(coordinate)
  end
end

#
class Rook < Piece
  def initialize(color, key: :r, multiline: true)
    super
  end

  def scope(coordinate)
    line_wise_directions(coordinate)
  end
end

#
class Pawn < Piece
  def initialize(color, key: :p, multiline: false)
    super
  end

  def scope(coordinate)
    x = coordinate[0]
    y = coordinate[1]

    filter(
      [
        [[x + 1, y + 1]],
        [[x, y + 1], [x, y + 2]],
        [[x -1, y + 1]]
      ]
    )
  end
end
