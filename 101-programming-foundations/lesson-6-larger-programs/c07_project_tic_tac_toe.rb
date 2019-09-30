# LS Course 101 - Programming Foundations
# Lesson 6 - Slightly Larger Programs
# Chapter 07 - Tic-Tac-Toe Assignment Bonus Features (Updated)

# QUESTION
# Build a tic tac toe game
# The game is played between user and computer
# Determine the winner or if it's a tie
# Display the board and results

# BONUS FEATURES
# Choose board size based on user input
# Computer AI improvements
# Alternate first turn between player and computer
# Keeping score

$stdout.sync = true # To display output immediately on windows using git bash

require 'colorize'

# CONFIGURATIONS - set a valid value to have different game behavior

# Board size valid values - 'choose', 3 to 9
# Other sizes will have unexpected behavior...err...I think so...
BOARD_SIZE = 'choose'
# Difficulty valid values - 'choose', 1, 2, 3
DIFFICULTY = 'choose'
# First turn Valid values - 'choose', 'player', 'computer'
# 'choose' lets the user choose who goes first
FIRST_TURN = 'choose'
# First Turn Mode Valid values - 'alternate', 'fixed'.
# 'alternate' switches the first turn between player and computer every round
FIRST_TURN_MODE = 'alternate'

# END OF CONFIGURATIONS

AVAILABLE_BOARD_SIZE = [3, 4, 5, 6, 7, 8, 9]
DIFFICULTY_TABLE = { 1 => 'Easy', 2 => 'Medium', 3 => 'Hard' }
PLAYERS = ['player', 'computer']
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'

def prompt(msg)
  puts "=> #{msg}"
end

def check_interger(num)
  num = num.to_s

  if /^[+-]?\d*\.?0*$/.match(num) && /\d/.match(num)
    if num.to_i.positive?
      'positive'
    elsif num.to_i.negative?
      'negative'
    else
      'zero'
    end
  else
    'invalid'
  end
end

def join_extended(arr, delimiter = ', ', end_word = 'or')
  arr = arr.dup

  case arr.size
  when 0 then ''
  when 1 then arr.first
  else
    last = arr.pop
    arr.join(delimiter) << " #{end_word} #{last}"
  end
end

def display_welcome_message
  puts
  puts <<~welcome
  Let's play Tic-Tac-Toe
  My record #{'999 wins'.green} and #{'0 loss'.yellow}
  Be proud you are going to be my #{'1000th'.green}

  The first to win 5 rounds wins the game
  welcome
  puts
end

def receive_name
  prompt('What is your name?')
  name = gets.chomp.strip.capitalize

  name = 'Edgelord' if name.empty?
  puts "Hello, #{name}!"
  puts

  name
end

def choose_board_size
  return BOARD_SIZE unless BOARD_SIZE == 'choose'

  loop do
    prompt("Choose a board size. Type '3' for a 3 x 3 board")
    prompt("Choices: #{join_extended(AVAILABLE_BOARD_SIZE)}")
    board_size = gets.chomp

    if AVAILABLE_BOARD_SIZE.include?(board_size.to_i) &&
       check_interger(board_size) == 'positive'
      break board_size.to_i
    end
    puts "'#{board_size}' is not a valid choice"
  end
end

def choose_difficulty(game_details)
  return DIFFICULTY unless DIFFICULTY == 'choose'

  name = game_details['name']
  puts
  display_difficulty_options(name)

  difficulty = ''
  loop do
    difficulty = gets.chomp
    if [1, 2, 3].include?(difficulty.to_i) &&
       check_interger(difficulty) == 'positive'
      break
    end

    prompt('Choose 1, 2, or 3')
  end
  difficulty.to_i
end

def display_difficulty_options(name)
  prompt("#{name}, choose a difficulty")
  prompt("Type 1 for Easy")
  prompt("Type 2 for Medium")
  prompt("Type 3 for Hard")
end

def choose_first_turn(game_details)
  return FIRST_TURN unless FIRST_TURN == 'choose'

  name = game_details['name']

  puts
  prompt("Choose who would take the first turn")
  prompt("Type 1 for #{name}")
  prompt("Type 2 for Computer")

  loop do
    first_turn = gets.chomp

    if check_interger(first_turn) == 'positive'
      break 'player' if first_turn.to_i == 1
      break 'computer' if first_turn.to_i == 2
    end

    prompt("Choose 1 for #{name}, 2 for Computer")
  end
end

def initialize_board(game_details)
  size = game_details['board_size']

  new_board = {}
  (1..size**2).each { |num| new_board[num] = num.to_s }
  new_board
end

def find_winning_lines(brd)
  num_of_squares = brd.size
  size = Math.sqrt(num_of_squares).to_i

  rows = find_winning_lines_rows(size)
  columns = find_winning_lines_columns(size, num_of_squares)
  diagonals = find_winning_lines_diagonals(size, num_of_squares)

  rows + columns + diagonals
end

def find_winning_lines_rows(size)
  rows = Array.new(size) { Array.new }
  size.times do |idx|
    (1..size).each { |i| rows[idx] << (size * idx + i) }
  end
  rows
end

def find_winning_lines_columns(size, num_of_squares)
  columns = Array.new(size) { Array.new }
  size.times do |idx|
    1.step(num_of_squares, size) { |step| columns[idx] << idx + step }
  end
  columns
end

def find_winning_lines_diagonals(size, num_of_squares)
  diagonals = Array.new(2) { Array.new }
  1.step(num_of_squares, size + 1) { |i| diagonals[0] << i }
  size.step(num_of_squares - 1, size - 1) { |i| diagonals[1] << i }

  diagonals
end

def display_board(brd, game_details)
  brd = apply_marker_color(brd)

  size = game_details['board_size']
  print_lines = (4 * size) - 1

  display_round_number(game_details)
  display_markers(game_details)
  display_difficulty(game_details)
  puts
  display_grid_with_values(brd, size, print_lines)
  puts
end

def apply_marker_color(brd)
  brd = brd.dup
  brd.each do |sq_num, sq_value|
    brd[sq_num] = if sq_value == PLAYER_MARKER
                    sq_value.red
                  elsif sq_value == COMPUTER_MARKER
                    sq_value.blue
                  else
                    sq_value.white
                  end
  end
  brd
end

def display_round_number(game_details)
  size = game_details['board_size']
  round_number = game_details['round_number']

  puts "[ROUND #{round_number}]".center(8 * size)
end

def display_markers(game_details)
  size = game_details['board_size']
  name = game_details['name']
  p_marker = PLAYER_MARKER.red
  c_marker = COMPUTER_MARKER.blue

  puts "#{name}: #{p_marker} | Computer: #{c_marker}".center(10 * size + 20)
end

def display_difficulty(game_details)
  size = game_details['board_size']
  difficulty = game_details['difficulty']

  puts "Difficulty: #{DIFFICULTY_TABLE[difficulty]}".center(8 * size)
end

# rubocop:disable all
def display_grid_with_values(brd, size, print_lines)
  (1..print_lines).each do |num|
    if num % 4 == 1 || num % 4 == 3
      puts((["       "] * size).join('|'))
    elsif num % 4 == 2
      start_value = ((num / 4) * size) + 1
      end_value = start_value + size - 1

      print_arr = []
      (start_value..end_value).each do |key|
        print_arr << if brd[key].uncolorize.size == 3
                       "  #{brd[key]}  "
                     elsif brd[key].uncolorize.size == 2
                       "   #{brd[key]}  "
                     else
                       "   #{brd[key]}   "
                     end
      end
      puts print_arr.join('|')
    else
      puts((["-------"] * size).join('+'))
    end
  end
end
# rubocop:enable all

def place_piece!(brd, current_player, game_details)
  case current_player
  when 'player'
    choice = player_choice(brd, game_details)
    brd[choice] = PLAYER_MARKER
    game_details['player_choice'] = choice
  when 'computer'
    choice = generate_computer_choice(brd, game_details)
    brd[choice] = COMPUTER_MARKER
    game_details['computer_choice'] = choice
  end
end

def player_choice(brd, game_details)
  name = game_details['name']

  player_choice = ''
  loop do
    prompt("[#{name}'s turn] Choose a square")
    prompt('The numbers visible on the board are available')
    player_choice = gets.chomp

    break if valid_choice?(brd, player_choice)
    puts "'#{player_choice}' is not a valid choice"
  end
  player_choice.to_i
end

def valid_choice?(brd, choice)
  return false unless check_interger(choice) == 'positive'

  empty_squares(brd).include?(choice.to_i)
end

def generate_computer_choice(brd, game_details)
  difficulty = game_details['difficulty']

  if difficulty == 2 || difficulty == 3
    choice = find_medium_choice(brd)
    return choice if choice
  end

  if difficulty == 3
    choice = find_hard_choice(brd)
    return choice if choice
  end

  empty_squares(brd).sample
end

def find_medium_choice(brd)
  choice = find_critical_square(brd, COMPUTER_MARKER)
  return choice if choice

  choice = find_critical_square(brd, PLAYER_MARKER)
  return choice if choice
end

def find_hard_choice(brd)
  if brd.size.odd?
    center_num = brd.size / 2 + 1
    return center_num if empty_squares(brd).include?(center_num)
  end

  choice = find_risky_square(brd, PLAYER_MARKER)
  return choice if choice

  choice = find_risky_square(brd, COMPUTER_MARKER)
  return choice if choice
end

def find_critical_square(brd, marker)
  num_of_squares = brd.size
  size = Math.sqrt(num_of_squares).to_i

  @winning_lines.each do |line|
    combined_value = brd.values_at(*line)
    if combined_value.count(marker) == size - 1
      square = combined_value - [PLAYER_MARKER, COMPUTER_MARKER]
      return square.first.to_i if square.first
    end
  end
  nil
end

def find_risky_square(brd, marker)
  num_of_squares = brd.size
  size = Math.sqrt(num_of_squares).to_i

  if size > 3
    @winning_lines.each do |line|
      combined_value = brd.values_at(*line)
      if combined_value.count(marker) == size - 2
        square = combined_value - [PLAYER_MARKER, COMPUTER_MARKER]
        return square.first.to_i if square.size == 2 && square.first
      end
    end
  end
  nil
end

def empty_squares(brd)
  brd.keys.reject { |key| [PLAYER_MARKER, COMPUTER_MARKER].include?(brd[key]) }
end

def next_player(current_player)
  current_index = PLAYERS.index(current_player)

  current_index >= PLAYERS.size - 1 ? PLAYERS[0] : PLAYERS[current_index + 1]
end

def round_won?(brd)
  !!detect_round_winner(brd)
end

def detect_round_winner(brd)
  num_of_squares = brd.size
  size = Math.sqrt(num_of_squares).to_i

  @winning_lines.each do |line|
    combined_value = brd.values_at(*line)
    return 'player' if combined_value.count(PLAYER_MARKER) == size
    return 'computer' if combined_value.count(COMPUTER_MARKER) == size
  end
  nil
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def display_computer_choice(game_details)
  computer_choice = game_details['computer_choice']

  puts "Computer chose square #{computer_choice}"
  puts
end

def display_scorecard(game_details)
  name = game_details['name']
  player_score = game_details['player_score']
  computer_score = game_details['computer_score']
  tie = game_details['tie']

  puts "[SCORECARD] #{name}: #{player_score} | Computer: #{computer_score}"\
       " | Tie: #{tie}"
  puts
end

def display_round_result(brd)
  if detect_round_winner(brd) == 'player'
    puts "You win this round"
  elsif detect_round_winner(brd) == 'computer'
    puts "Computer wins this round"
  else
    puts "It's a tie"
  end
end

def update_game_details(brd, game_details)
  round_result = detect_round_winner(brd)
  game_details['player_score']   += 1 if     round_result == 'player'
  game_details['computer_score'] += 1 if     round_result == 'computer'
  game_details['tie']            += 1 unless round_result
  game_details['round_number']   += 1
end

def game_won?(game_details)
  game_details['player_score'] == 5 || game_details['computer_score'] == 5
end

def display_winning_message(game_details)
  player_score = game_details['player_score']
  computer_score = game_details['computer_score']
  give_up = game_details['give_up']

  display_give_up_message if give_up

  if player_score == 5
    display_player_win_message
  elsif computer_score == 5
    display_computer_win_message
  end
  puts
end

def display_give_up_message
  puts 'Now you know how I get my wins MUHAHAHA'
  puts "Go ahead LOSER, I'll let you weep <evil laughter>..."
  sleep(2)
end

def display_player_win_message
  puts 'Wow you beat me not once but five times'
  puts 'You must be a mastermind!!!'
  puts 'Or maybe try increasing the difficult?'
end

def display_computer_win_message
  puts 'Take that. You messed with the wrong person kid'
end

def determine_whoose_turn(first_turn)
  if FIRST_TURN_MODE == 'alternate'
    (PLAYERS - [first_turn]).first
  else
    first_turn
  end
end

def give_up(game_details)
  give_up = nil

  if game_details['tie'] >= 5
    prompt('Tired? Type y to give up or any key to continue')
    reply = gets.chomp

    if reply.downcase == 'y'
      game_details['give_up'] = true
      give_up = 'yes'
    else
      give_up = 'no'
    end
  end

  return true if give_up == 'yes'
  return false if give_up == 'no'

  press_enter_to_continue
  false
end

def press_enter_to_continue
  print "Press enter/return key to go to next round..."
  gets
end

def play_again?
  loop do
    prompt('Do you want to play again? (y or n)')
    play_again = gets.chomp

    return true if play_again.downcase == 'y'
    return false if play_again.downcase == 'n'

    puts "'#{play_again}' is not a valid choice"
  end
end

def play_round_until_result(board, game_details, current_player)
  loop do
    clear_screen
    display_scorecard(game_details)
    display_board(board, game_details)
    display_computer_choice(game_details) if game_details['computer_choice']

    place_piece!(board, current_player, game_details)
    current_player = next_player(current_player)
    break if round_won?(board) || board_full?(board)
  end
end

def clear_screen
  puts "\e[H\e[2J"
end

def display_line_divider
  90.times { print '-' }
  puts
end

display_welcome_message
name = receive_name

loop do
  game_details = {
    'name' => name,
    'board_size' => 3,
    'difficulty' => 1,
    'round_number' => 1,
    'player_score' => 0,
    'computer_score' => 0,
    'tie' => 0,
    'player_choice' => nil,
    'computer_choice' => nil,
    'give_up' => false
  }

  game_details['board_size'] = choose_board_size
  game_details['difficulty'] = choose_difficulty(game_details)
  first_turn = choose_first_turn(game_details)

  loop do
    board = initialize_board(game_details)
    @winning_lines = find_winning_lines(board)

    current_player = first_turn
    game_details['computer_choice'] = nil

    play_round_until_result(board, game_details, current_player)

    clear_screen
    display_board(board, game_details)
    display_round_result(board)
    update_game_details(board, game_details)
    display_scorecard(game_details)

    break display_winning_message(game_details) if game_won?(game_details)
    return display_winning_message(game_details) if give_up(game_details)

    first_turn = determine_whoose_turn(first_turn)
  end

  break unless play_again?
end

puts 'Thanks for playing Tic-Tac-Toe. Have a nice day'
puts
