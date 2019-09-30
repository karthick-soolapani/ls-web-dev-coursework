# LS Course 120 - Object Oriented Programming
# Lesson 5 - Slightly larger OO programs
# Chapter 07 - OO Tic Tac Toe with bonus features

$stdout.sync = true # To display output immediately on windows using git bash

require 'colorize'

module UXAmplifiers
  def prompt(msg)
    puts "=> #{msg}".blue
  end

  def display_divider
    50.times { print '-' }
    puts nil
  end

  def display_clear_screen
    puts "\e[H\e[2J"
  end

  def enter_to_continue
    puts nil
    prompt('Press enter/return to continue...')
    gets
  end

  def check_integer(num)
    num = num.to_s

    if /^[+-]?\d*\.?0*$/.match(num) && /\d/.match(num)
      return :positive if num.to_i.positive?
      return :negative if num.to_i.negative?
      :zero
    else
      :invalid
    end
  end
end

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],
                   [1, 5, 9], [3, 5, 7]]
  SIZE = 3
  attr_reader :squares

  def initialize
    @squares = formulate_squares
  end

  def generate_draw_lines
    lines = [
      "     |     |     ",
      "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}  ",
      "     |     |     ",
      "-----+-----+-----",
      "     |     |     ",
      "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}  ",
      "     |     |     ",
      "-----+-----+-----",
      "     |     |     ",
      "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}  ",
      "     |     |     "
    ]

    lines
  end

  def unmarked_sq_nums
    @squares.reject { |_, square| square.marked? }.keys
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def full?
    unmarked_sq_nums.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      marked_squares = @squares.values_at(*line).select(&:marked?)
      markers = marked_squares.map(&:marker)
      markers.each { |marker| return marker if markers.count(marker) == SIZE }
    end
    nil
  end

  private

  def formulate_squares
    (1..9).map { |idx| [idx, Square.new(idx.to_s.white)] }.to_h
  end
end

class Square
  attr_accessor :marker

  def initialize(marker)
    @marker = marker
  end

  def marked?
    !('1'..'9').include?(marker.uncolorize)
  end

  def to_s
    @marker
  end
end

class Player
  include UXAmplifiers
  attr_reader :name, :marker
  attr_accessor :choice
end

class Human < Player
  def initialize
    determine_name
  end

  def determine_marker
    puts nil
    marker_choice = nil

    loop do
      prompt("Choose one alphabet for your marker (A-Z)")
      marker_choice = gets.chomp

      break if ('A'..'Z').include?(marker_choice.strip.upcase)
      puts "'#{marker_choice}' is not a valid choice"
    end

    @marker = marker_choice.strip.upcase.green
  end

  def move!(board)
    square = nil

    loop do
      prompt("Choose a square - numbers visible on the board are available")
      square = gets.chomp

      break if valid_square?(square, board)
      puts "'#{square}' is not a valid choice"
    end

    @choice = square.to_i
    board[@choice] = marker
  end

  private

  def determine_name
    prompt("How would you like me to call you?")
    answer = gets.chomp

    if answer.strip.empty?
      answer = %w[Dovahkiin Neo Samus Rambo Achilles].sample
      puts "Alright, we will call you #{answer.green} then"
    else
      puts "Hello, #{answer.capitalize.green}"
    end

    @name = answer.capitalize.green
  end

  def valid_square?(choice, board)
    return false unless check_integer(choice) == :positive

    board.unmarked_sq_nums.include?(choice.to_i)
  end
end

class Computer < Player
  COMPUTER_MATRIX = {
    'pikachu'   => Proc.new { Pikachu.new },
    'yorha-2b'  => Proc.new { Yorha2B.new },
    'hal-9000'  => Proc.new { Hal9000.new }
  }

  COMPUTERS = %w[(P)ikachu (Y)oRHa-2B (H)AL-9000]

  COMPUTER_PERSONALITIES = [
    'Pikachu loves THAT square',
    '2B has no battle plan as she has lost contact with HQ',
    'Hal is calm, intelligent, extremely rational and is reactive'
  ]

  def determine_marker(available_markers)
    return @marker = 'O'.red if available_markers.include?('O')

    @marker = available_markers.sample.red
  end

  def move!(board)
    @choice = board.unmarked_sq_nums.sample

    board[@choice] = marker
  end
end

class Pikachu < Computer
  def initialize
    @name = 'Pikachu'.red
  end

  def move!(board)
    center_num = 5
    if board.unmarked_sq_nums.include?(center_num)
      @choice = center_num
      board[@choice] = marker
      return
    end

    super
  end
end

class Yorha2B < Computer
  def initialize
    @name = 'YoRHa-2B'.red
  end
end

class Hal9000 < Computer
  def initialize
    @name = 'HAL-9000'.red
  end

  def move!(board)
    @choice = find_offense_choice(board)
    return board[@choice] = marker if @choice

    @choice = find_defense_choice(board)
    return board[@choice] = marker if @choice

    super
  end

  private

  def find_offense_choice(board)
    Board::WINNING_LINES.each do |line|
      mark_sqs, unmark_sqs = board.squares.values_at(*line).partition(&:marked?)

      comp_count = mark_sqs.count { |sq| sq.marker == marker }

      if comp_count == (Board::SIZE - 1) && !unmark_sqs.empty?
        return line.find { |sq_num| !board.squares[sq_num].marked? }
      end
    end
    nil
  end

  def find_defense_choice(board)
    Board::WINNING_LINES.each do |line|
      mark_sqs, unmark_sqs = board.squares.values_at(*line).partition(&:marked?)

      human_count = mark_sqs.count { |sq| sq.marker != marker }

      if human_count == (Board::SIZE - 1) && !unmark_sqs.empty?
        return line.find { |sq_num| !board.squares[sq_num].marked? }
      end
    end
    nil
  end
end

class Scorecard
  include UXAmplifiers
  attr_reader :score

  def initialize(human, computer)
    @human = human
    @computer = computer
    @score = { human: 0, computer: 0, tie: 0 }
    @round_number = 1
  end

  def display_round_number
    width = TTTGame::FORMAT_WIDTH
    puts "[ROUND - #{@round_number}]".center(width)
  end

  def update_score(winner)
    @score[winner] += 1
  end

  def increment_round_number
    @round_number += 1
  end

  def display_scorecard
    win_score = TTTGame::WIN_SCORE
    score_array = ["#{@human.name} - #{score[:human]}/#{win_score}",
                   "#{@computer.name} - #{score[:computer]}/#{win_score}",
                   "#{'Tie'.yellow} - #{score[:tie]}"]
    formatted_scores = score_array.join('  |  ')

    puts formatted_scores
  end
end

class TTTGame
  include UXAmplifiers
  FIRST_TURN = 'choose' # valid values - 'human', 'computer', 'choose'
  WIN_SCORE = 3
  FORMAT_WIDTH = 32
  BOARD_PADDING = 8
  attr_reader :board, :human, :computer, :scorecard

  def initialize
    display_welcome_message
    @give_up = false
  end

  def play
    setup_human

    loop do
      setup_computer
      determine_first_turn
      setup_scorecard

      play_rounds until game_won? || give_up?
      display_game_winner_message

      break unless play_again?
      display_clear_screen
    end

    display_goodbye_message
  end

  private

  def display_welcome_message
    display_clear_screen
    puts <<~welcome
    Let's play Tic Tac Toe
    The first to win #{"#{WIN_SCORE} ROUNDS".red.underline} is the grand winner
    welcome
    puts nil
  end

  def setup_human
    @human = Human.new

    human.determine_marker
  end

  def setup_computer
    choose_computer

    available_markers = ('A'..'Z').to_a - [human.marker.uncolorize]
    computer.determine_marker(available_markers)
  end

  def choose_computer
    display_comp_personality
    comp_choice = nil

    prompt("Who do you want to play against?")
    loop do
      prompt("Choose one - #{Computer::COMPUTERS.join(', ')}")
      comp_choice = gets.chomp

      break if valid_comp?(comp_choice.strip.downcase)
      puts "'#{comp_choice}' is invalid"
    end

    comp_choice = retrieve_valid(comp_choice.strip.downcase)
    @computer = Computer::COMPUTER_MATRIX[comp_choice].call
  end

  def display_comp_personality
    puts nil
    puts Computer::COMPUTER_PERSONALITIES
    puts nil
  end

  def valid_comp?(comp_choice)
    return false if comp_choice.empty?
    Computer::COMPUTER_MATRIX.keys.any? { |comp| comp.start_with?(comp_choice) }
  end

  def retrieve_valid(comp_choice)
    Computer::COMPUTER_MATRIX.keys.each do |valids|
      return valids if valids.start_with?(comp_choice)
    end
  end

  def determine_first_turn
    return @first_turn = human    if FIRST_TURN == 'human'
    return @first_turn = computer if FIRST_TURN == 'computer'

    @first_turn = choose_first_turn == 1 ? human : computer
  end

  def choose_first_turn
    puts nil

    loop do
      prompt("Choose who would go first:")
      prompt("Enter '1' for #{human.name} (OR) '2' for #{computer.name}")
      first_turn = gets.chomp

      if check_integer(first_turn) == :positive && first_turn.to_i <= 2
        break first_turn.to_i
      end

      puts "Sorry, '#{first_turn}' is not valid"
    end
  end

  def setup_scorecard
    @scorecard = Scorecard.new(human, computer)
  end

  def play_rounds
    setup_round
    play_turns until board.someone_won? || board.full?
    scorecard.update_score(who_won)
    display_round_summary
    scorecard.increment_round_number
    enter_to_continue unless game_won? || give_up_trigger?
  end

  def setup_round
    @board = Board.new
    @give_up = false
    human.choice = nil
    computer.choice = nil
    @current_player = @first_turn
  end

  def play_turns
    if human_turn?
      display_clear_screen
      scorecard.display_round_number
      scorecard.display_scorecard
      display_board
      display_computer_choice if computer.choice
    end

    current_player_moves
  end

  def human_turn?
    @current_player == human
  end

  def display_board
    player_markers = marker_identification
    lines = board.generate_draw_lines

    puts player_markers.join('    |  ')
    puts nil
    puts lines.map { |line| (' ' * BOARD_PADDING) + line }
    puts nil
  end

  def marker_identification
    ["#{human.name} - #{human.marker}", "#{computer.name} - #{computer.marker}"]
  end

  def display_computer_choice
    puts "#{computer.name} chose square #{computer.choice}"
    puts nil
  end

  def current_player_moves
    @current_player.move!(board)
    @current_player = next_player
  end

  def next_player
    @current_player == human ? computer : human
  end

  def who_won
    win_marker = board.winning_marker
    return :human    if win_marker == human.marker
    return :computer if win_marker == computer.marker
    :tie
  end

  def display_round_summary
    display_clear_screen

    scorecard.display_round_number
    display_board

    display_divider
    display_round_winner_message
    scorecard.display_scorecard
    display_divider
  end

  def display_round_winner_message
    case who_won
    when :human    then puts "#{human.name} won!".green
    when :computer then puts "#{computer.name} won!".red
    when :tie      then puts "It's a tie".yellow
    end
  end

  def game_won?
    player_score = scorecard.score[:human]
    computer_score = scorecard.score[:computer]

    player_score >= WIN_SCORE || computer_score >= WIN_SCORE
  end

  def give_up?
    return false unless give_up_trigger?

    puts nil
    prompt('Tired? Enter y to give up or any other key to continue')
    reply = gets.chomp

    return @give_up = true if reply.strip.downcase == 'y'
    false
  end

  def give_up_trigger?
    scorecard.score[:tie] >= WIN_SCORE
  end

  def display_game_winner_message
    puts nil
    if @give_up
      puts 'Now you know how I get my wins MUHAHAHA'
      puts "#{computer.name} is the undisputed champion"
    elsif scorecard.score[:human] >= WIN_SCORE
      puts "#{human.name} is crowned as the champion"
      puts "Try playing against a different opponent"
    else
      puts 'Take that. You messed with the wrong person kid'
    end
    puts nil
  end

  def play_again?
    prompt('Do you want to play again? (y or n)')
    loop do
      play_again = gets.chomp

      return true if %w[y yes].include?(play_again.downcase)
      return false if %w[n no].include?(play_again.downcase)

      prompt("Sorry, '#{play_again}' is invalid. Answer with y or n")
    end
  end

  def display_goodbye_message
    puts nil
    puts "Thank you for playing Tic Tac Toe! See you again!"
    puts nil
  end
end

TTTGame.new.play
