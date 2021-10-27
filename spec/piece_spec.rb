# frozen_string_literal: true

require_relative '../lib/board_elements/piece'

describe Piece do
  describe '#scope' do
    # king methods will be checked independently

    it "returns an array of arrays | each array is a collection
    of coordinates that in the line defined by the rules of a piece" do; end

    it "returns an array of arrays | the coordinates in the arrays are
    in order from nearest to farthest the coordinate" do; end

    it 'returns an array of arrays of points' do
      context 'when the piece is a knight in coordinate 3,2' do
        it "returns [[4, 4], [5, 3], [2, 4], [1, 3], [2, 0], [1, 1],
        [4, 0], [5, 1]" do
          coordinate = [3, 2]
          correct_scope =  [
            [[5, 3]], [[4, 4]], # Quadrant 1
            [[1, 3]], [[2, 4]], # Quadrant 2
            [[2, 0]], [[1, 1]], # Quadrant 3
            [[4, 0]], [[5, 1]]  # Quadrant 4
          ]

          calculated_scope = Knight.new(:white).scope(coordinate)

          expect(calculated_scope).to eq(correct_scope)
        end
      end

      context 'when the piece is a rook in coordinate 3, 3' do

        it "returns all the directional cells in the horizontal and
        vertical line passing throught 3, 3" do
          coordinate = [3, 3]
          correct_scope = [
            [*4..7].zip(Array.new(4, 3)),         # Quadrant 1
            Array.new(4, 3).zip([*4..7]),         # Quadrant 2
            [*0..2].zip(Array.new(3, 3)).reverse, # Quadrant 3
            Array.new(3, 3).zip([*0..2]).reverse  # Quadrant 4
          ]
          calculated_scope = Rook.new(:white).scope(coordinate) 

          expect(calculated_scope).to eq(correct_scope)
        end
      end

      context 'when the piece is a bishop in coordinate 3, 3' do
        it 'returns all the directional diagonals passing through 3, 3' do
          coordinate = [3, 3]
          correct_scope = [
            [*4..7].zip([*4..7]),           # Quadrant 1
            ([*0..2].reverse).zip([*4..6]), # Quadrant 2
            [*0..2].zip([*0..2]).reverse,   # Quadrant 3
            ([*4..6]).zip([*0..2].reverse)  # Quadrant 4
          ]
          calculated_scope = Bishop.new(:white).scope(coordinate)

          expect(calculated_scope).to eq(correct_scope)
        end
      end

      context 'when the piece is a queen in coordinate 2, 4' do
        it "returns all the directional diagonals, vertical and horizontals
        passing through 2, 4" do
          coordinate = [2, 4]
          correct_scope = [
            [*3..7].zip(Array.new(5, 4)),
            [*3..5].zip([*5..7]),
            Array.new(3, 2).zip([*5..7]),
            ([1, 0].reverse).zip([5, 6]),
            [1, 0].zip([4, 4]),
            [1, 0].zip([3, 2]),
            Array.new(4, 2).zip([*0..3]).reverse,
            [*3..6].zip([*0..3].reverse)
          ]
          calculated_scope = Queen.new(:white).scope(coordinate)

          expect(calculated_scope).to eq(correct_scope)
        end
      end

      context 'when the piece is a pawn in coordinate 1, 1' do
        it 'returns all the forward vertical and diagonal coordinates' do
          coordinate = [1, 1]
          correct_scope = [
            [[2, 2]],
            [[1, 2], [1, 3]],
            [[0, 2]]
          ]
          calculated_scope = Pawn.new(:white).scope(coordinate) 
          expect(calculated_scope).to eq(correct_scope)
        end
      end
    end
  end
end
