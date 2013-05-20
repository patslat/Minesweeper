class Minesweeper

end

class Board
  attr_reader :board

  def initialize(size)

    @size = size
    @board = build_board
  end

  def build_board
    Array.new(@size) { Array.new(@size) }
  end

  def generate_mines
    mine_coords = []
    mine_count = @size == 9 ? 10 : 40

    until mine_coords.length == mine_count
      row = (0...@size).to_a.sample
      col = (0...@size).to_a.sample
      mine_coords << [row, col] unless mine_coords.include?([row, col])
    end

    mine_coords.each do |coord|
      row, col = coord
      @board[row][col] = "X"
    end
  end
end

class Player

end