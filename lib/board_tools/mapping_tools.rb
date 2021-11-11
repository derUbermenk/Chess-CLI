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
  # @param cell [Cell]
  def map_paths_to(cell)
    cell.from_connections.each_value do |connection|
      if connection.piece
        new_path = get_path(make_direction(connection.coordinate, cell.coordinate))
        connection.update_path(cell.key, new_path) if connection.piece.multiline
      else
        next
      end
    end
  end

  # remaps all the cells for which cell has path leading to. This cells
  # ... are referenced thru cell.to_connections
  def map_paths_from(cell) 
    piece = cell.piece
    connections = piece.scope(cell.coordinate).map { |direction| get_path(direction) }
    cell.connect(connections)
  end

  # returns an array of keys of the to_connections where cell can move to
  # @param cell [Cell]
  # @return [Array]
  def filter_connections(cell)
    return [] if skewed?(cell)

    current_color = cell.piece.color
    current_king = king(current_color)

    if current_king.check
      return valid_connections = [] if current_king.check_count == 2

      valid_connections = cell.to_connections.each_with_object([]) do |direction, valid_connections_|
        # check removers would be all the to_connections of the given cell in check removers
        valid_connections_.concat(direction.keys.select { |key| current_king.check_removers.include?(key) })
      end
    else
      valid_connections = cell.to_connections.each_with_object([]) do |direction, valid_connections_|
        valid_connections_.concat(direction.select { |key, cell_| cell_.occupiable_by(current_color) }.keys)
      end
    end

  end

  # connection filter for cells containing king
  def filter_connections_king(cell)
    current_color = cell.piece.color
    opposite_color = current_color == :white ? :black : :white

    valid_connections = cell.to_connections.each_with_object([]) do |direction, valid_connections_|
      valid_connections_.concat(direction.values.select do |cell_|
        # not checked current color, checks if any of the from connections has
        # a piece that is opposite to current color
        cell_.not_checked_by(opposite_color) && cell_.occupiable_by(current_color)
      end)
    end

    valid_connections.map(&:key)
  end

  #### HELPER #####

  # converts an array of cell convertibles to cells
  # @param line [Array] either an array of coordinates -- direction
  # ... or an array of cell_keys
  def convert_to_cells(line, db = @board_cartesian, input = :coords)
    line.map do |id|
      equiv_cell(id, db, input)
    end
  end

  def equiv_cell(id, db = @board_cartesian, input = :coords)
    case input
    when :coords
      x = id[0]
      y = id[1]
      db[y][x]
    when :cell_key
      db[id]
    end
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

  def convert_to_keys(to_connections)
    to_connections.each_with_object([]) do |direction, keys|
      #direction.each_value { |cell| keys << cell.key }
      keys.concat(direction.values.map(&:key))
    end
  end

  # A y function
  class LinearEquation
    attr_reader :slope

    def initialize(point1, point2)
      @point1 = point1
      @point2 = point2
      @slope = fn_slope
      @y_intercept = fn_y_intercept

      @domain = fn_domain
    end

    def ordered_pair(allowed_range)
      return [] if @point1 == @point2

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

      return 0 if y2 == y1

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

  # Cell connector
  class CellConnector

    def initialize(db)
      @db = db
    end

    # connects cells to its to connections
    def connect(cell, connections)
      cell.to_connections = connections.map do |direction|
        direction.each_with_object({}) do |cell_, direction_|
          add_ref(cell, cell_)
          direction_[cell_.key] = cell_.piece
        end
      end
    end

    # disconnect cells from all its to connections
    def disconnect(cell, board_db)
      connections = cell.to_connections.map(&:keys).flatten 
      connections.each { |key| delete_ref(cell, board_db[key]) }
      cell.to_connections = []
    end

    def update_path(cell, new_path)
      nearest_cell = new_path.first

      cell.to_connections.map! do |old_path|
        # the old path to be updated with the new path contains the same set of keys
        if old_path[nearest_cell.key]
          adjust_path(cell, old_path, new_path)
        else
          old_path
        end
      end
    end

    private

    # adds a reference to referenced_cell in cell2.from_connections
    def add_ref(referenced_cell, cell2)
      cell2.from_connections[referenced_cell.key] = referenced_cell.piece
    end

    # deletes reference to referenced_cell in cell2.from_connections 
    def delete_ref(referenced_cell, cell2)
      cell2.from_connections.delete(referenced_cell.key)
    end

    # @param origin [Cell]
    # @param old_path [Hash] containing cell_key and piece 
    # @param new_path [Array] array of cells 
    def adjust_path(origin, old_path, new_path)
      if old_path.size > new_path.size
        cut_path(origin, old_path, new_path)
      elsif old_path.size < new_path.size
        extend_path(origin, old_path, new_path)
      end
    end

    # deletes the ref to self in all from connections in old path that are not 
    # ... in new path
    # @param origin [Cell]
    # @param old_path [Hash] containing cell_key and piece 
    # @param new_path [Array] array of cells 
    def cut_path(origin, old_path, new_path)
      old_path = convert_to_cells(old_path)
      excluded_cells = old_path - new_path
      excluded_cells.map { |excluded_cell| delete_ref(origin, excluded_cell) }

      convert_to_cell_format(new_path)
    end

    # adds a ref to self in all the from connections in the new path that were
    # ... initially not in the old path
    # @param origin [Cell]
    # @param old_path [Hash] containing cell_key and piece 
    # @param new_path [Array] array of cells 
    def extend_path(origin, old_path, new_path)
      puts 'im here'
      old_path = convert_to_cells(old_path)
      additional_cells = new_path - old_path
      puts "some path #{additional_cells}"
      additional_cells.map{ |additional_cell| add_ref(origin, additional_cell) }

      convert_to_cell_format(new_path)
    end

    def convert_to_cells(path)
      path.each_key.with_object([]) do |key, path|
        path << @db[key]
      end
    end

    # converts a path -- an array of cell into cell format
    # @param path [Array]
    def convert_to_cell_format(path)
      path.each_with_object({}) do |cell, path_format| 
        path_format[cell.key] = cell.piece
      end
    end
  end
end
