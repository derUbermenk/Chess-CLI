# frozen_string_literal: true

require_relative '../board'

# NOTE 
# 
# * direction
#     a direction is an array of coordinates with reference from a cell
#     that is sorted by distance to the reference cell, determined by the
#     piece in the ref cell and bounded by the limits of the coordinates of
#     a board.
#
# * path
#     extracted from direction. An array of empty cells up to the first
#     nonempty cell.
#
# END

# mapping functions for board
module MappingTools

  # remaps the connections to and from the cell
  # ... assuming a piece has been placed
  # @param cell [Cell]
  def placement_remap(cell)
    map_paths_to(cell)
    map_paths_from(cell)
  end

  # remaps connections to and from cell
  # ... assuming a piece has been removed
  # @param cell [Cell]
  def removal_remap(cell)
    map_paths_to(cell)

    cell.disconnect
  end

  # maps all the cells that have paths to cell. This cells are
  # ... referenced through cell.from_connections
  def map_paths_to(cell)
    cell.from_connections.each_value do |connection|
      new_path = get_path(make_direction(connection.coordinate, cell.coordinate))
      connection.update_path(cell, new_path) if connection.piece.multiline
    end
  end

  # remaps all the cells for which cell has path leading to. This cells
  # ... are referenced thru cell.to_connections
  def map_paths_from(cell)
    piece = cell.piece
    connections = piece.scope(cell.coordinate).map { |direction| get_path(direction) }
    # change opposite color king check if position of the color is in connections
    # do relevant remapping of valid connections
    cell.connect(connections)
  end

  #### HELPER #####

  # converts an array of directions(array of cells) to cell collections
  # @param direction [Array] array of coordinates 
  def convert_to_cells(direction)
    direction.map do |coordinate|
      to_cell(coordinate)
    end
  end

  def to_cell(coordinate)
    x = coordinate[0]
    y = coordinate[1]
    @board_cartesian[y][x]
  end

  # make a direction from point_start through through_point
  # up to the bounds of the cell
  # @param start_point [Array] excluded from direction
  # @param through_point [Array] included in direction
  def make_direction(start_point, through_point)
    y = LinearEquation.new(start_point, through_point)

    y.ordered_pair([*0..7])
  end

  # given a direction get the path -- the array of cells from nearest to piece
  # up to the first non-empty cell.
  # @param direction [Array] array of coordinates
  def get_path(direction)
    cell_equivalents = convert_to_cells(direction)

    # find the first non empty cell. but add the empty cells
    # ... and the first non empty cell to path in the process.
    cell_equivalents.find.with_object({}) do |cell, path|
      path[cell.key] = cell
      !cell.piece.nil?
    end
  end

  # A y function
  class LinearEquation
    def initialize(point1, point2)
      @point1 = point1
      @point2 = point2
      @slope = fn_slope
      @y_intercept = fn_y_intercept

      @domain = fn_domain
    end

    def ordered_pair(allowed_range)
      return vertical_line if @slope.nil?

      return horizontal_line if @slope.zero?

      @domain.each_with_object([]) do |x, range|
        y = fn(x)
        range << [x, y.to_i] if allowed_range.include?(y)
      end
    end

    # solve for y given x
    def fn(x_value)
      (@slope * x_value) + @y_intercept
    end

    private

    def fn_domain
      x_ref = @point1[0] # xstart is not included in domain
      x_pass = @point2[0]

      return [x_ref] if @slope.nil?

      # the domain is reversed when starting from 0 because the points
      # ... are sorted by distance to point1
      x_pass < x_ref ? [*0...x_ref].reverse : [*(x_ref + 1)..7]
    end

    def fn_slope
      x1 = @point1[0]
      y1 = @point1[1]

      x2 = @point2[0]
      y2 = @point2[1]

      return nil if x2 == x1

      (y2 - y1) / (x2 - x1).to_f
    end

    def fn_y_intercept
      return nil if @slope.nil?

      x = @point2[0]
      y = @point2[1]

      y - (@slope * x)
    end

    def vertical_line
      y_ref = @point1[1]
      y_pass = @point2[1]

      # the range is reversed when starting from 0 because the points 
      # ... are sorted by distance to point1
      range = y_pass < y_ref ? [*0...y_ref].reverse : [*(y_ref + 1)..7]
      Array.new(range.size, @domain[0]).zip(range)
    end

    def horizontal_line
      y_ref = @point1[1]
      @domain.zip(Array.new(@domain.size, y_ref))
    end
  end
end
