# LS Course 101 - Programming Foundations
# Lesson 2 - Small Programs
# Chapter 22 - Rock Paper Scissors Spock Lizard Game

# QUESTION
# The user makes a choice
# The computer makes a choice
# Find the winner
# Whoever gets to 5 wins first is the grand winner

$stdout.sync = true # To display output immediately on windows using git bash

WIN_MATRIX = {
  'rock'     => %w(lizard scissors),
  'paper'    => %w(rock spock),
  'scissors' => %w(paper lizard),
  'spock'    => %w(scissors rock),
  'lizard'   => %w(spock paper)
}
GAME_CHOICES = WIN_MATRIX.keys
WIN_SCORE = 5

def prompt(message)
  puts "=> #{message}"
end

def receive_choice_from_player
  player_choice = ''
  prompt('Choose one - rock, paper, scissors, spock, lizard')
  loop do
    player_choice = gets.chomp

    if player_choice.strip.downcase == 's'
      prompt("Enter 'sc' for scissors and 'sp' for Spock")
      next
    end

    break if valid_choice?(player_choice.strip.downcase)

    prompt("'#{player_choice}' is not a valid choice")
  end
  retrieve_actual_choice(player_choice.strip.downcase)
end

def valid_choice?(player_choice)
  return false if player_choice.empty?

  GAME_CHOICES.each do |valid_choice|
    return true if valid_choice.start_with?(player_choice)
  end
  false
end

def retrieve_actual_choice(player_choice)
  GAME_CHOICES.each do |valid_choice|
    return valid_choice if valid_choice.start_with?(player_choice)
  end
end

def who_wins(round_details)
  player_choice = round_details['player_choice']
  computer_choice = round_details['computer_choice']

  if WIN_MATRIX[player_choice].include?(computer_choice)
    'player'
  elsif player_choice == computer_choice
    'tie'
  else
    'computer'
  end
end

def display_round_result(result, round_details)
  round_number = round_details['round_number']
  player_choice = round_details['player_choice']
  computer_choice = round_details['computer_choice']

  puts "You chose: #{player_choice}; computer chose: #{computer_choice}"
  case result
  when 'player'   then puts "Round ##{round_number}: You win!"
  when 'tie'      then puts "Round ##{round_number}: It's a tie!"
  when 'computer' then puts "Round ##{round_number}: Computer wins!"
  end
end

def display_scorecard(round_details)
  round_number = round_details['round_number']
  player_score = round_details['player_score']
  computer_score = round_details['computer_score']

  puts
  puts "Scorecard after Round ##{round_number - 1} -"
  puts "You: #{player_score} win(s); Computer: #{computer_score} win(s)"
  display_line_divider
end

def display_line_divider
  90.times { print '-' }
  puts
end

def clear_screen
  puts "\e[H\e[2J"
end

puts
puts <<~welcome
Let's play Rock Paper Scissors Spock Lizard
I know it's daunting but just choose one and hope \
the RNG Gods are on your side :)
The first to win 5 rounds wins the game
welcome
display_line_divider

round_details = {
  'round_number' => 1,
  'player_score' => 0,
  'computer_score' => 0,
  'player_choice' => '',
  'computer_choice' => ''
}

loop do
  puts "ROUND #{round_details['round_number']} - FIGHT!"
  puts

  round_details['player_choice'] = receive_choice_from_player
  round_details['computer_choice'] = GAME_CHOICES.sample

  game_result = who_wins(round_details)

  clear_screen

  puts ''
  display_round_result(game_result, round_details)

  round_details['player_score']   += 1 if game_result == 'player'
  round_details['computer_score'] += 1 if game_result == 'computer'
  round_details['round_number']   += 1

  display_scorecard(round_details)
  sleep 1

  if round_details['player_score'] == WIN_SCORE
    puts "Yea you win. It doesn't bother me sniff...sniff..."
    break
  elsif round_details['computer_score'] == WIN_SCORE
    puts "FATALITY! I'm the undisputed champion"
    puts "I'll let you walk away in disgrace MUHAHAHA"
    break
  end

  if (round_details['player_score']   == WIN_SCORE - 1) &&
     (round_details['computer_score'] == WIN_SCORE - 1)
    puts "Things have gotten intense"
    puts "Close your eyes and pray. I'll rig... er nothing"
  end
end

display_line_divider
