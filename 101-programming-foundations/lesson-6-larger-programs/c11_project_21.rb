# LS Course 101 - Programming Foundations
# Lesson 6 - Slightly Larger Programs
# Chapter 08 - Assignment - Twenty-One game with bonus features

# QUESTION
# Build a 21 game starting with a normal 52-card deck
# The game consists of dealer and player starting with 2 cards
# Each can choose to hit or stay
# If value goes over 21 then game over
# Whoever has the higher value wins the game

# BONUS FEATURES
# Cache total
# Grand output
# Keep score
# Configurable limit for 21 - 31, 41 etc.
# Varied coloring & bust probability

$stdout.sync = true # To display output immediately on windows using git bash

require 'colorize'

CARD_VALUES_MATRIX = { '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6,
                       '7' => 7, '8' => 8, '9' => 9, '10' => 10,
                       'J' => 10, 'Q' => 10, 'K' => 10, 'A' => 11 }
SUITS = { 'S' => 'Spade', 'H' => 'Hearts', 'D' => 'Diamond', 'C' => 'Clubs' }
FACE_CARDS = { 'J' => 'Jack', 'Q' => 'Queen', 'K' => 'King', 'A' => 'Ace' }
WIN_SCORE = 1
SAFE_LIMIT = 21
PLAYER_THRESHOLD = 17
DEALER_THRESHOLD = 17
RISK_PERCENTAGE = 65

def prompt(msg)
  puts "=> #{msg}"
end

def clear_screen
  puts "\e[H\e[2J"
end

def display_line_divider(length)
  length.times { print '-' }
  puts
end

def press_enter_to_continue
  print "Press enter/return key to go to next round..."
  gets
end

def format_number(num)
  num = format('%.2f', num)

  if num.to_f == num.to_i
    format('%g', num)
  else
    num
  end
end

def display_welcome_message
  puts
  puts <<~welcome
  Let's play a modified version of 21
  The first to win 5 rounds is the CHAMPION
  welcome
  puts
end

def initialize_deck
  cards = CARD_VALUES_MATRIX.keys
  deck = []

  SUITS.keys.each do |suit|
    cards.each { |card| deck << [suit, card] }
  end
  deck.shuffle
end

def deal_cards(deck)
  player_cards = []
  dealer_cards = []

  2.times do
    player_cards << deck.shift
    dealer_cards << deck.shift
  end

  return player_cards, dealer_cards
end

def hand_total(cards)
  values = cards.map { |_suit, value| value }

  sum = values.map { |key| CARD_VALUES_MATRIX[key] }.sum
  values.count('A').times { sum -= 10 if sum > SAFE_LIMIT }

  sum
end

def display_scorecard(game_details)
  player_score = game_details[:player_score]
  dealer_score = game_details[:dealer_score]
  tie = game_details[:tie]

  puts "[SCORECARD] You: #{player_score} | Dealer: #{dealer_score}"\
       " | Tie: #{tie}".light_magenta
end

def display_round_number(game_details)
  round_number = game_details[:round_number]

  puts "[ROUND #{round_number}]".center(40).light_magenta
  puts
end

def show_one_dealer_card(dealer_cards)
  card = dealer_cards[0]
  sum = hand_total([card])
  suit, value = convert_to_readable_format(card)

  puts "Dealer has #{value} of #{suit} and ?"
  puts "Dealer hand value = #{sum}+"
end

def show_player_cards(player_cards, game_details)
  player_total = game_details[:player_total]
  width = 20

  puts
  puts "Your Hand"
  puts ''.ljust(width, '-')
  puts formatted_player_cards(player_cards)
  puts ''.ljust(width, '=')
  puts formatted_player_total(player_total)
  puts
end

def formatted_player_cards(player_cards)
  formatted_cards = []
  player_cards.each_with_index do |card, idx|
    suit, value = convert_to_readable_format(card)
    if value == 'Ace'
      formatted_cards << "#{idx + 1}. #{"#{value} of #{suit}".blue}"
    else
      formatted_cards << "#{idx + 1}. #{value} of #{suit}"
    end
  end
  formatted_cards
end

def formatted_player_total(player_total)
  if player_total >= PLAYER_THRESHOLD
    "Total = #{player_total.to_s.red}"
  else
    "Total = #{player_total.to_s.green}"
  end
end

def display_safe_points_left(game_details)
  player_total = game_details[:player_total]
  difference = SAFE_LIMIT - player_total

  if player_total >= PLAYER_THRESHOLD
    puts "Safe points left = #{difference.to_s.red}"
  else
    puts "Safe points left = #{difference.to_s.green}"
  end
end

def display_bust_probability(deck, player_cards, dealer_cards)
  probability = calculate_bust_probability(deck, player_cards, dealer_cards)
  percentage = probability * 100
  formatted_percentage = format_number(percentage)

  if percentage > RISK_PERCENTAGE
    puts "Probability of bust = #{"#{formatted_percentage}%".red}"
  else
    puts "Probability of bust = #{"#{formatted_percentage}%".green}"
  end
  puts
end

def calculate_bust_probability(deck, player_cards, dealer_cards)
  deck = deck.dup
  deck << dealer_cards[1]
  bust_arr = deck.map do |card|
    new_cards = player_cards + [card]
    cards_total = hand_total(new_cards)
    cards_total > SAFE_LIMIT ? 1 : 0
  end

  (bust_arr.sum.to_f / bust_arr.size).round(4)
end

def show_both_hand(player_cards, dealer_cards, game_details)
  width = 20
  player_total = game_details[:player_total]
  dealer_total = game_details[:dealer_total]

  size = if player_cards.size > dealer_cards.size
           player_cards.size
         else
           dealer_cards.size
         end

  player_cards_readable = formatted_readable_cards(player_cards, width, size)
  dealer_cards_readable = formatted_readable_cards(dealer_cards, width, size)
  zipped_array = player_cards_readable.zip(dealer_cards_readable)

  display_hand_grid(zipped_array, player_total, dealer_total, width)
end

# rubocop:disable Metrics/LineLength
def formatted_readable_cards(cards, width, size)
  cards_readable = Array.new(size) { String.new.ljust(width) }
  cards.each_with_index do |card, idx|
    suit, value = convert_to_readable_format(card)
    if value == 'Ace'
      cards_readable[idx] = "#{idx + 1}. #{"#{value} of #{suit}".ljust(width - 3).blue}"
    else
      cards_readable[idx] = "#{idx + 1}. #{value} of #{suit}".ljust(width)
    end
  end
  cards_readable
end
# rubocop:enable Metrics/LineLength

# rubocop:disable Metrics/AbcSize
def display_hand_grid(zipped_array, player_total, dealer_total, width)
  puts
  puts "Your hand".ljust(width) + '| ' + "Dealer hand"
  puts ''.ljust(width, '-') + "+" + ''.ljust(width, '-')
  zipped_array.each { |arr| puts arr.join('| ') }
  puts ''.ljust(width, '=') + "+" + ''.ljust(width, '=')
  puts "Total = #{player_total}".ljust(width) + "| "\
       "Total = #{dealer_total}"
  puts
end
# rubocop:enable Metrics/AbcSize

def convert_to_readable_format(card)
  suit = SUITS[card[0]]

  value = if card[1].to_i == 0
            FACE_CARDS[card[1]]
          else
            card[1].to_i
          end

  return suit, value
end

def hit!(deck, cards)
  cards << deck.shift
end

def busted?(total)
  total > SAFE_LIMIT
end

def detect_round_result(game_details)
  player_total = game_details[:player_total]
  dealer_total = game_details[:dealer_total]

  if player_total > SAFE_LIMIT
    :player_busted
  elsif dealer_total > SAFE_LIMIT
    :dealer_busted
  elsif player_total > dealer_total
    :player_wins
  elsif dealer_total > player_total
    :dealer_wins
  else
    :tie
  end
end

def display_round_result(player_cards, dealer_cards, game_details)
  round_result = detect_round_result(game_details)

  show_both_hand(player_cards, dealer_cards, game_details)

  case round_result
  when :player_busted then puts "You're BUSTED. Dealer wins".red
  when :dealer_busted then puts "Dealer busted. YOU WIN".green
  when :player_wins   then puts 'YOU WIN!'.green
  when :dealer_wins   then puts 'Dealer wins!'.red
  when :tie           then puts "It's a tie".yellow
  end
end

def game_won?(game_details)
  player_score = game_details[:player_score]
  dealer_score = game_details[:dealer_score]

  player_score == WIN_SCORE || dealer_score == WIN_SCORE
end

def update_game_details(game_details)
  round_result = detect_round_result(game_details)
  player_win_arr = [:dealer_busted, :player_wins]
  dealer_win_arr = [:player_busted, :dealer_wins]

  game_details[:player_score]   += 1 if player_win_arr.include?(round_result)
  game_details[:dealer_score]   += 1 if dealer_win_arr.include?(round_result)
  game_details[:tie]            += 1 if round_result == :tie
  game_details[:round_number]   += 1
end

def display_winning_message(game_details)
  player_score = game_details[:player_score]

  display_line_divider(51)

  if player_score == WIN_SCORE
    puts "I'm utterly defeated...Luck is no excuse"
    puts "I crown you as the CHAMPION"
  else
    puts "FATALITY...What!? you are saying I got lucky?"
    puts "Git gud, scrub"
  end
end

def play_again
  answer = nil

  display_line_divider(51)
  prompt("Do you want to play again? (y or n)")
  loop do
    answer = gets.chomp.downcase

    break answer if ['y', 'n'].include?(answer)
    prompt("Invalid choice. 'y' for yes, 'n' for no")
  end
end

# rubocop:disable Metrics/MethodLength
def player_move(deck, player_cards, dealer_cards, game_details)
  prompt("Do you want to Hit or Stay?")
  player_choice = prompt_choice_until_valid

  clear_screen
  display_scorecard(game_details)
  display_round_number(game_details)

  if player_choice == 'h'
    puts "You've chosen to Hit"
    hit!(deck, player_cards)
    game_details[:player_total] = hand_total(player_cards)
    unless busted?(game_details[:player_total])
      show_player_cards(player_cards, game_details)
      display_safe_points_left(game_details)
      display_bust_probability(deck, player_cards, dealer_cards)
    end
  end
  player_choice
end
# rubocop:enable Metrics/MethodLength

def prompt_choice_until_valid
  player_choice = nil
  loop do
    prompt("Type 'h' for Hit, 's' for Stay")
    player_choice = gets.chomp

    break if ['h', 's'].include?(player_choice.downcase)
    puts "'#{player_choice}' is not a valid choice"
  end
  player_choice.downcase
end

def dealer_move(deck, dealer_cards, game_details)
  puts "The dealer chose to Hit"
  hit!(deck, dealer_cards)
  game_details[:dealer_total] = hand_total(dealer_cards)
  unless busted?(game_details[:dealer_total])
    puts "No. of dealer cards = #{dealer_cards.size}"
    puts
    puts "Thinking..."
    sleep(2)
  end
end

# rubocop:disable Metrics/LineLength
display_welcome_message

loop do
  game_details = {
    round_number: 1,
    player_score: 0,
    dealer_score: 0,
    tie: 0,
    player_total: 0,
    dealer_total: 0
  }

  loop do
    deck = initialize_deck
    player_cards, dealer_cards = deal_cards(deck)
    game_details[:player_total] = hand_total(player_cards)
    game_details[:dealer_total] = hand_total(dealer_cards)

    display_scorecard(game_details)
    display_round_number(game_details)
    show_one_dealer_card(dealer_cards)
    show_player_cards(player_cards, game_details)
    display_safe_points_left(game_details)
    display_bust_probability(deck, player_cards, dealer_cards)

    puts "[YOUR TURN]"

    player_choice = nil
    until player_choice == 's' || busted?(game_details[:player_total])
      player_choice = player_move(deck, player_cards, dealer_cards, game_details)
    end

    if busted?(game_details[:player_total])
      display_round_result(player_cards, dealer_cards, game_details)
      update_game_details(game_details)
      display_scorecard(game_details)
      puts
      break if game_won?(game_details)
      press_enter_to_continue
      next clear_screen
    end

    puts "You've chosen to Stay"
    puts "Total hand value = #{game_details[:player_total]}"

    puts "\n[DEALER TURN]\n\n"
    puts "Thinking..."
    sleep(2)

    until game_details[:dealer_total] >= DEALER_THRESHOLD
      dealer_move(deck, dealer_cards, game_details)
    end

    if busted?(game_details[:dealer_total])
      display_round_result(player_cards, dealer_cards, game_details)
      update_game_details(game_details)
      display_scorecard(game_details)
      puts
      break if game_won?(game_details)
      press_enter_to_continue
      next clear_screen
    end

    puts "Dealer chose to Stay"
    puts "Total hand value = #{game_details[:dealer_total]}"

    display_round_result(player_cards, dealer_cards, game_details)
    update_game_details(game_details)
    display_scorecard(game_details)
    puts

    break if game_won?(game_details)
    press_enter_to_continue
    clear_screen
  end

  display_winning_message(game_details)
  break unless play_again == 'y'
  clear_screen
end

puts "\nThank you for playing Twenty-One. Have a nice day\n\n"
# rubocop:enable Metrics/LineLength
