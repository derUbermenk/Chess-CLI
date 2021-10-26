# frozen_string_literal:true

# a module for storing chess symbols to be displayed in board
module ChessSymbols
  # white
  WHITE_SQUARE = "\u25A0"
  WHITE_PAWN = "\u265F"
  WHITE_KNIGHT = "\u265E"
  WHITE_BISHOP = "\u265D"
  WHITE_ROOK = "\u265C"
  WHITE_QUEEN = "\u265B"
  WHITE_KING = "\u265A"
  # black
  BLACK_SQUARE = "\u25A1"
  BLACK_PAWN = "\u2659"
  BLACK_KNIGHT = "\u2658"
  BLACK_BISHOP = "\u2657"
  BLACK_ROOK = "\u2656"
  BLACK_QUEEN = "\u2655"
  BLACK_KING = "\u2654"

  PIECES = {
    p: { white: WHITE_PAWN, black: BLACK_PAWN },
    n: { white: WHITE_KNIGHT, black: BLACK_KNIGHT },
    b: { white: WHITE_BISHOP, black: BLACK_BISHOP },
    r: { white: WHITE_ROOK, black: BLACK_ROOK },
    q: { white: WHITE_QUEEN, black: BLACK_QUEEN },
    k: { white: WHITE_KING, black: BLACK_KING }
  }

  # @param piece_key [Symbol]
  # @param color [Symbol]
  # returns the appropriate symbol given the key color
  def set_symbol(piece_key, color)
    PIECES[piece_key][color]
  end
end
