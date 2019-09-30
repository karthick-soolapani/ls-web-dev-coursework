$stdout.sync = true # To display output immediately on windows using git bash

require 'colorize'

module UXAmplifiers
  def prompt(msg)
    puts "=> #{msg}".blue
  end

  def display_divider
    40.times { print '-' }
    puts nil
  end

  def display_clear_screen
    puts "\e[H\e[2J"
  end

  def enter_to_next_round
    puts nil
    prompt('Press enter/return to go to next round...')
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
end

class Deck
  attr_reader :cards

  def initialize
    @cards = []
    total_cards = Card::SUITS.product(Card::CARD_VALUES.keys)
    total_cards.each { |suit, number| @cards << Card.new(suit, number) }
    @cards.shuffle!
  end

  def deal_one
    @cards.pop
  end
end

class Card
  CARD_VALUES = { '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7,
                  '8' => 8, '9' => 9, '10' => 10, 'J' => 10, 'Q' => 10,
                  'K' => 10, 'A' => 11 }
  SUITS = %w[Spade Hearts Diamond Clubs]
  COLORS = { 'Spade' => :light_black, 'Hearts' => :red, 'Diamond' => :red,
             'Clubs' => :light_black }

  attr_reader :suit, :number, :value, :symbol, :color
  private :suit, :number, :symbol

  def initialize(suit, number)
    @suit = suit
    @number = number
    @value = CARD_VALUES[number]
    @symbol = determine_symbol
    @color = COLORS[suit]
  end

  def determine_symbol
    case suit
    when 'Spade'    then "\u2660".unicode_normalize
    when 'Hearts'   then "\u2665".unicode_normalize
    when 'Diamond'  then "\u2666".unicode_normalize
    when 'Clubs'    then "\u2663".unicode_normalize
    end
  end

  def ace?
    @number == 'A'
  end

  def to_s
    "#{number} #{symbol}"
  end
end

class Participant
  include UXAmplifiers

  VALID_CHOICES = %w[hit stay]

  attr_reader :name, :cards, :choice
  attr_accessor :total

  def initialize
    set_name
    @cards = []
  end

  def calculate_total(cards = self.cards)
    num_of_aces = cards.count(&:ace?)
    total = cards.map(&:value).sum

    num_of_aces.times { total -= 10 if total > TwentyOneGame::SAFE_LIMIT }
    total
  end

  def stay?
    choice == 'stay'
  end

  def busted?
    total > TwentyOneGame::SAFE_LIMIT
  end

  def >(other)
    total > other.total
  end

  def <(other)
    total < other.total
  end

  def ==(other)
    total == other.total
  end

  def reset
    @cards = []
    @choice = nil
  end
end

class Player < Participant
  PLAYER_THRESHOLD = 17
  CRITICAL_BUST_PERCENTAGE = 65
  RISKY_BUST_PERCENTAGE = 50

  def choose_move
    player_choice = nil
    loop do
      prompt("Do you want to (h)it or (s)tay?")
      player_choice = gets.chomp

      break if valid_choice?(player_choice.strip.downcase)
      puts "'#{player_choice}' is not a valid choice"
    end

    @choice = retrieve_valid(player_choice.strip.downcase)
  end

  def display_safe_points_left
    difference = TwentyOneGame::SAFE_LIMIT - total

    if total >= PLAYER_THRESHOLD
      puts "Safe points left = #{difference.to_s.red}"
    else
      puts "Safe points left = #{difference.to_s.green}"
    end
  end

  def display_bust_probability(remaining_cards)
    probability = calculate_bust_probability(remaining_cards)
    percentage = probability * 100
    formatted_percentage = format_number(percentage)

    if percentage >= CRITICAL_BUST_PERCENTAGE
      puts "Probability of bust = #{"#{formatted_percentage}%".red}"
    elsif percentage >= RISKY_BUST_PERCENTAGE
      puts "Probability of bust = #{"#{formatted_percentage}%".yellow}"
    else
      puts "Probability of bust = #{"#{formatted_percentage}%".green}"
    end

    puts nil
  end

  private

  def set_name
    prompt("How would you like me to call you?")
    answer = gets.chomp

    if answer.strip.empty?
      answer = %w[Dovahkiin Neo Samus Rambo Achilles].sample
      puts "Alright, we will call you #{answer.green} then..."
      sleep(1)
    else
      puts "Hello, #{answer.strip.capitalize.green}"
    end

    @name = answer.strip.capitalize.green
  end

  def calculate_bust_probability(remaining_cards)
    bust_arr = remaining_cards.map do |card|
      new_cards = cards + [card]
      cards_total = calculate_total(new_cards)
      cards_total > TwentyOneGame::SAFE_LIMIT ? 1 : 0
    end

    (bust_arr.sum.to_f / bust_arr.size).round(4)
  end

  def valid_choice?(player_choice)
    return false if player_choice.empty?
    VALID_CHOICES.any? { |choice| choice.start_with?(player_choice) }
  end

  def retrieve_valid(player_choice)
    VALID_CHOICES.each do |choice|
      return choice if choice.start_with?(player_choice)
    end
  end
end

class Dealer < Participant
  DEALERS = %w[GLaDOS Pikachu YoRHa-2B HAL-9000 Alita]
  DEALER_THRESHOLD = 17

  def choose_move
    puts nil
    print "#{name} is thinking"

    2.times do
      print '...'
      sleep(1)
    end
    puts nil

    @choice = total < DEALER_THRESHOLD ? 'hit' : 'stay'
  end

  def partial_total
    cards[0].value
  end

  private

  def set_name
    @name = DEALERS.sample.red
  end
end

class Scorecard
  include UXAmplifiers
  attr_reader :score

  def initialize(player, dealer)
    @player = player
    @dealer = dealer
    @score = { player: 0, dealer: 0, tie: 0 }
    @round_number = 1
  end

  def update_score(winner)
    @score[winner] += 1
  end

  def display_scorecard
    win_score = TwentyOneGame::WIN_SCORE
    score_array = ["#{@player.name} - #{score[:player]}/#{win_score}",
                   "#{@dealer.name} - #{score[:dealer]}/#{win_score}",
                   "#{'Tie'.yellow} - #{score[:tie]}"]
    formatted_scores = score_array.join(' | ')

    puts formatted_scores
  end
end

class Round
  include UXAmplifiers
  @@round_number = 0

  attr_reader :deck, :player, :dealer, :scorecard, :winner
  private :deck, :player, :dealer, :scorecard

  def initialize(player, dealer, scorecard)
    @player = player
    @dealer = dealer
    @scorecard = scorecard
    @winner = nil
    @@round_number += 1
    reset_participants
  end

  def play
    setup_deck
    deal_initial_cards
    player_turn
    dealer_turn unless player.busted?

    set_winner
    display_clear_screen
    show_cards(dealer_hidden: false)
    display_divider
    display_result
  end

  def self.reset_round_number
    @@round_number = 0
  end

  private

  def setup_deck
    @deck = Deck.new
  end

  def deal_initial_cards
    2.times do
      player.cards << deck.deal_one
      dealer.cards << deck.deal_one
    end

    player.total = player.calculate_total
    dealer.total = dealer.calculate_total
  end

  # rubocop:disable Metrics/AbcSize
  def player_turn
    until player.stay? || player.busted?
      display_clear_screen
      display_round_number
      scorecard.display_scorecard
      show_cards
      display_player_aide

      player.choose_move
      next display_player_stay_message if player.stay?

      hit!(player)
      display_player_hit_message
    end
  end
  # rubocop:enable Metrics/AbcSize

  def dealer_turn
    until dealer.stay? || dealer.busted?
      dealer.choose_move
      next display_dealer_stay_message if dealer.stay?

      hit!(dealer)
      display_dealer_hit_message
    end
  end

  def display_round_number
    width = 32
    puts "[ROUND - #{@@round_number}]".center(width)
  end

  def show_cards(dealer_hidden: true)
    player_cards = player.cards
    dealer_cards = dealer.cards

    size = [player_cards.size, dealer_cards.size].max

    player_cards_formatted = format_cards(player_cards, size)
    dealer_cards_formatted = format_cards(dealer_cards, size)

    hide_one_dealer_card(dealer_cards_formatted) if dealer_hidden

    formatted_cards = player_cards_formatted.zip(dealer_cards_formatted)
    hand_grid = form_hand_grid(formatted_cards)

    adjust_total(hand_grid) if dealer_hidden
    puts hand_grid
  end

  def format_cards(cards, size)
    width = TwentyOneGame::SHOW_CARDS_WIDTH

    formatted_cards = Array.new(size) { String.new.ljust(width) }
    cards.each_with_index do |card, idx|
      num = "#{idx + 1}. "
      if card.ace?
        formatted_cards[idx] = num + card.to_s.ljust(width - 3).blue
      else
        formatted_cards[idx] = num + card.to_s.ljust(width - 3).send(card.color)
      end
    end
    formatted_cards
  end

  # rubocop:disable Metrics/AbcSize
  def form_hand_grid(cards)
    width = TwentyOneGame::SHOW_CARDS_WIDTH

    [nil,
     "Your hand".ljust(width) + '| ' + "Dealer's hand",
     ''.ljust(width, '-') + "+" + ''.ljust(width, '-'),
     cards.map { |arr| arr.join('| ') },
     ''.ljust(width, '=') + "+" + ''.ljust(width, '='),
     "Total = #{player.total}".ljust(width) + "| Total = #{dealer.total}",
     nil]
  end
  # rubocop:enable Metrics/AbcSize

  def hide_one_dealer_card(cards)
    cards[1] = "2. ??".ljust(TwentyOneGame::SHOW_CARDS_WIDTH)
  end

  def adjust_total(hand_grid)
    partial_total = dealer.partial_total
    start = TwentyOneGame::SHOW_CARDS_WIDTH + 10

    hand_grid[-2][start..-1] = "#{partial_total}+"
  end

  def display_player_aide
    player.display_safe_points_left

    remaining_cards = deck.cards + [dealer.cards[1]]
    player.display_bust_probability(remaining_cards)
  end

  def display_player_stay_message
    puts nil
    puts "#{player.name} has chosen to Stay"
    puts "Total hand value = #{player.total}".green
  end

  def display_dealer_stay_message
    puts nil
    puts "#{dealer.name} has chosen to Stay"
    puts "Total hand value = #{dealer.total}".red
  end

  def display_player_hit_message
    puts "#{player.name} has chosen to Hit"
  end

  def display_dealer_hit_message
    puts nil
    puts "#{dealer.name} has chosen to Hit"
    puts "Cards in #{dealer.name}'s hand = #{dealer.cards.size}"
    puts nil
  end

  def hit!(participant)
    participant.cards << deck.cards.shift
    participant.total = participant.calculate_total
  end

  def detect_win_method
    if player.busted?
      :player_busted
    elsif dealer.busted?
      :dealer_busted
    elsif player > dealer
      :player_wins
    elsif player < dealer
      :dealer_wins
    else
      :tie
    end
  end

  def set_winner
    case detect_win_method
    when :player_wins, :dealer_busted then @winner = :player
    when :dealer_wins, :player_busted then @winner = :dealer
    else                                   @winner = :tie
    end
  end

  def display_result
    pl_name = player.name
    dl_name = dealer.name

    case detect_win_method
    when :player_busted then puts "#{pl_name} BUSTED. #{dl_name} wins".red
    when :dealer_busted then puts "#{dl_name} BUSTED. #{pl_name} wins".green
    when :player_wins   then puts "#{pl_name} WINS!".green
    when :dealer_wins   then puts "#{dl_name} wins!".red
    when :tie           then puts "It's a tie".yellow
    end
  end

  def reset_participants
    player.reset
    dealer.reset
  end
end

class TwentyOneGame
  include UXAmplifiers

  WIN_SCORE = 3
  SAFE_LIMIT = 21
  SHOW_CARDS_WIDTH = 15

  attr_reader :player, :dealer, :scorecard, :current_round
  private :player, :dealer, :scorecard, :current_round

  def initialize
    display_welcome_message
    setup_participants
  end

  # rubocop:disable Metrics/AbcSize
  def play
    setup_scorecard

    loop do
      setup_round

      current_round.play

      scorecard.update_score(current_round.winner)
      scorecard.display_scorecard
      display_divider

      break display_game_winner_message if game_won?
      enter_to_next_round
    end

    reset
    play_again? ? play : display_goodbye_message
  end
  # rubocop:enable Metrics/AbcSize

  private

  def display_welcome_message
    display_clear_screen
    puts <<~welcome
    Let's play a simplified version of blackjack called 21
    The first to win #{"#{WIN_SCORE} ROUNDS".red.underline} is the CHAMPION
    welcome
    puts nil
  end

  def setup_participants
    @player = Player.new
    @dealer = Dealer.new
  end

  def setup_scorecard
    @scorecard = Scorecard.new(player, dealer)
  end

  def setup_round
    @current_round = Round.new(player, dealer, scorecard)
  end

  def game_won?
    player_score = scorecard.score[:player]
    dealer_score = scorecard.score[:dealer]

    player_score >= WIN_SCORE || dealer_score >= WIN_SCORE
  end

  def display_game_winner_message
    puts nil
    if scorecard.score[:player] >= WIN_SCORE
      puts "#{player.name} is crowned as the champion"
    else
      puts 'Take that. You messed with the wrong person kid'
    end
    puts nil
  end

  def reset
    Round.reset_round_number
  end

  def play_again?
    prompt('Do you want to play again? (y or n)')
    loop do
      play_again = gets.chomp

      return true if %w[y yes].include?(play_again.strip.downcase)
      return false if %w[n no].include?(play_again.strip.downcase)

      prompt("Sorry, '#{play_again}' is invalid. Answer with y or n")
    end
  end

  def display_goodbye_message
    puts nil
    puts "Thank you for playing Twenty-One. Have a nice day"
    puts nil
  end
end

TwentyOneGame.new.play
