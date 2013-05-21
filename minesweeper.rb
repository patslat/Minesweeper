require "json"
require "yaml"
class Minesweeper

  def initialize(board, player)
    @board = board
    @player = player
  end

  def play
    # load_game if load_game?
    start_time = Time.now

    # flag, row, col = get_move
    # player.move
    #
    # until valid_move?
    #   prompt_invalid
    #   player.move
    # end
    # flag, row, col
    @board.show
    flag, row, col = get_move until @board.valid_move?([row, col])
    # save && quit if flag == :save
    # flag, row, col = get_move
    @board.set_board(row, col)
    flag == :flag ? @board.flag(row, col) : @board.reveal(row, col)
    until game_over?
      @board.show
      flag, row, col = get_move until @board.valid_move?([row, col])
      flag == :flag ? @board.flag(row, col) : @board.reveal(row, col)
    end

    prompt_won if won?
    prompt_lost if lost?
    puts "Completed in #{(Time.now - start_time).round(2)} seconds!"
  end

  def game_over?
    won? || lost?
  end

  def won?
    @board.all_spaces_revealed?
  end

  def prompt_won
    puts "You won!"
  end

  def prompt_lost
    puts "You lost!"
  end

  def lost?
    @board.mine_revealed?
  end

  def get_move
    prompt_user
    flag, row, col = @player.move
    [flag, row, col]
  end

  def prompt_user
    print "Input move: "
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
  end

  def build_board
    Array.new(@size) { Array.new(@size) }
  end

  def set_board(row, col)
    generate_mines(row, col)
    generate_fringe
  end

  def show
    print " " * 5
    @size.times { |col| print "#{col} ".ljust(3)}
    print "\n"
    print " " * 4
    print "_" * (@size * 3) + "\n"
    @size.times do |row|
      print "#{row}".ljust(3) + "|  "
      @size.times do |col|
        if @revealed.include?([row, col])
          print "#{@board[row][col]}  "
        elsif @flagged.include?([row, col])
          print "F  "
        else
          print "-  "
        end
      end
      print "|"
      print "\n"
    end
    print " " * 4
    print "_" * (@size * 3) + "\n\n"
    nil
  end

  def mine_revealed?
    @revealed.any? do |row, col|
      @board[row][col] == "X"
    end
  end

  def all_spaces_revealed?
    @revealed.length == @size ** 2 - @mine_count
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

  def generate_mines(row, col)
    mine_coords = []
    ignore = [[row, col]] + get_adjacent_coords(row, col)
    until mine_coords.length == @mine_count
      row = (0...@size).to_a.sample
      col = (0...@size).to_a.sample
      mine_coords << [row, col] unless mine_coords.include?([row, col]) || ignore.include?([row, col])
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
    # diffs = [[-1, 1], [0, -1]]
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

  def on_board?(move)
    move.all? { |coord| coord.between?(0, @size) }
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
    input = gets.chomp

    flag = input.include?("F") ? :flag : nil
    flag = :save if input.include?("save")

    row, col = input.scan(/\d+/).map(&:to_i)
    [flag, row, col]
  end



end


if __FILE__ == $PROGRAM_NAME
  board = Board.new(9)
  player = Player.new(board)
  game = Minesweeper.new(board, player)
  game.play

 #  File.open("minesweeper_small.yml", "w"){ |f| f.write(game.to_yaml) }
 #
 #  board = Board.new(16)
 #  player = Player.new(board)
 #  game = Minesweeper.new(board, player)
 #
 #  File.open("minesweeper_large.yml", "w"){ |f| f.write(game.to_yaml) }
 #  new_game = YAML.load(File.open("minesweeper_large.yml"))
end