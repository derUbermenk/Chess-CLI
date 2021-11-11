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
      direction.each { |key, cell| cell.add_ref(self)}
    end
  end

  # checks if the given cell is connected to self
  # via a to_connection.
  def connected?(cell)
    !cell.from_connections[@key].nil?
  end

  def disconnect
    to_connections = @to_connections.map(&:values).flatten
    to_connections.each { |cell| cell.delete_ref(self) }

    @to_connections = []
  end

  # update the path -- in to_connections containing the given cell
  # @param cell_key [Symbol] search for the path with the given cell key
  # @param new_path [Array] new array of path to replace said path
  def update_path(cell_key, new_path)
    @to_connections.map! do |path| 
      if path[cell_key]
        old_path = path

        old_path.size > new_path.size ? cut_path(old_path, new_path) : extend_path(old_path, new_path)
      else
        path
      end
    end
  end

  # returns a hash of the from connections containing a piece of the given color 
  def checking_cells(color)
    @from_connections.select { |cell_key, piece| piece.color == color }
  end

  # check if self has no from connections
  # containing a piece of the given color 
  # @param color [Symbol]
  def not_checked_by(color)
    @from_connections.values.all? do |piece| 
      piece.color != color
    end
  end

  def occupiable_by(color)
    @piece.nil? || @piece.color != color
  end

  # the piece of the cell or the square 
  # ... if no piece is available
  def show
    piece&.symbol || square
  end


  # adds a reference to the given cell in the from connections of self
  # @param cell [Cell]
  def add_ref(cell)
    @from_connections[cell.key] = cell 
  end

  # deletes the reference to the given cell in the from connection
  # of self
  # @param cell [Cell]
  def delete_ref(cell)
    @from_connections.delete(cell.key)
  end

  private

  # deletes the ref to self in all from connections in old path that are not 
  # ... in new path
  # @param old_path [Hash]
  # @param new_path [Hash]
  def cut_path(old_path, new_path)
    excluded_cells = (old_path.keys - new_path.keys).map { |key| old_path[key] }
    excluded_cells.map { |cell| cell.delete_ref(self) }

    new_path
  end

  # adds a ref to self in all the from connections in the new path that were
  # ... initially not in the old path
  # @param old_path [Hash]
  # @param new_path [Hash]
  def extend_path(old_path, new_path)
    new_cells = (new_path.keys - old_path.keys).map { |key| new_path[key] }
    new_cells.map { |cell| cell.add_ref(self) }

    new_path
  end
end
