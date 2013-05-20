class Minesweeper

  def initialize(board, player)
    @board = board
    @player = player
  end

  def play

    until game_over?
      flag, row, col = @player.move
      flag ? @board.flag(row, col) : @board.reveal(row, col)
    end

    puts won? ? "You won!" : "You lost!"

  end

  def game_over?
    won? || lost?
  end

  def won?
    @board.all_spaces_revealed?
  end

  def lost?
    @board.mine_revealed?
  end

end

class Board
  attr_reader :board

  def initialize(size)
    @revealed = []
    @flagged = []
    @size = size
    @board = build_board
    @mine_count = @size == 9 ? 10 : 40
    generate_mines
    generate_fringe
  end

  def build_board
    Array.new(@size) { Array.new(@size) }
  end

  def show
    @size.times do |row|
      @size.times do |col|
        if @revealed.include?([row, col])
          print "#{@board[row][col]}  "
        elsif @flagged.include?([row, col])
          print "F  "
        else
          print "-  "
        end
      end
      print "\n"
    end
    nil
  end

  def mine_revealed?
    @revealed.any? do |row, col|
      @board[row][col] == "X"
    end
  end

  def all_spaces_revealed?
    @revealed.length == @size**2 - @mine_count
  end

  def flag(row, col)
    @flagged.include?([row, col]) ? @flagged.delete([row, col]) : @flagged << [row, col]
  end

  def reveal(row, col)
    @revealed << [row, col]
    # game over if its a bomb
    expand(row, col) if @board[row][col] == 0
  end

  def expand(row, col)
    adjacent_coords = get_adjacent_coords(row, col)
    adjacent_coords.each do |row, col|
      if @board[row][col] != "X" && !@revealed.include?([row, col])
        @revealed << [row, col]
        expand(row, col) if @board[row][col] == 0
      end
    end


  end

  def generate_mines
    mine_coords = []

    until mine_coords.length == @mine_count
      row = (0...@size).to_a.sample
      col = (0...@size).to_a.sample
      mine_coords << [row, col] unless mine_coords.include?([row, col])
    end

    mine_coords.each do |coord|
      row, col = coord
      @board[row][col] = "X"
    end
  end

  def generate_fringe
    @board.length.times do |row|
      @board.length.times do |col|
        next if @board[row][col] == "X"
        @board[row][col] = count_adjacent_mines(row, col)
      end
    end
  end

  def count_adjacent_mines(row, col)
    count = get_adjacent_values(row, col).select { |val| val == "X" }.count
  end

  def get_adjacent_coords(row, col)
    adjacents = [[row - 1, col + 1], [row, col + 1], [row + 1, col + 1],
    [row - 1, col], [row + 1, col], [row - 1, col - 1], [row, col - 1], [row + 1, col - 1]]

    adjacents.reject { |coord| coord.include?(-1) || coord.include?(@size) }
  end

  def get_adjacent_values(row, col)
    coords = get_adjacent_coords(row, col)
    values = []
    coords.each do |row, col|
      values << @board[row][col]
    end
    values
  end

  def valid_move?(move)
    row, col = move
    (0...@size).include?(row) && (0...@size).include?(col) && !@revealed.include?(move)
  end
end

class Player

  def initialize(board)
    @board = board
  end

  def move
    @board.show
    puts "Print move (add F if you want to flag):  row, column"
    input = gets.chomp
    flag = input.include?("F") ? true : false
    row, col = input.scan(/\d/).map(&:to_i)

    until @board.valid_move?([row, col])
      puts "Invalid move"
      input = gets.chomp
      flag = input.include?("F") ? true : false
      row, col = input.scan(/\d/).map(&:to_i)
    end
    [flag, row, col]
  end

end


if __FILE__ == $PROGRAM_NAME
  board = Board.new(9)
  player = Player.new(board)
  game = Minesweeper.new(board, player)
  game.play

end