# LS Course 120 - Object Oriented Programming
# Lesson 2 - OOP
# Chapter 16 - OO Rock Paper Scissors Spock Lizard with bonus features

$stdout.sync = true # To display output immediately on windows using git bash

require 'colorize'
require 'singleton'

module UXAmplifiers
  def prompt(msg)
    puts "=> #{msg}".blue
  end

  def display_divider
    60.times { print '-' }
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
end

class MoveHistory
  include Singleton
  attr_reader :move_history

  def initialize
    @move_history = Hash.new { Array.new }
  end

  def update_history(name, move)
    @move_history[name] += [move]
  end
end

class Move
  WIN_MATRIX = { 'rock'     => %w[lizard scissors],
                 'paper'    => %w[rock spock],
                 'scissors' => %w[paper lizard],
                 'spock'    => %w[scissors rock],
                 'lizard'   => %w[spock paper] }

  LOSE_MATRIX = { 'rock'     => %w[paper spock],
                  'paper'    => %w[scissors lizard],
                  'scissors' => %w[rock spock],
                  'spock'    => %w[paper lizard],
                  'lizard'   => %w[rock scissors] }

  VALID_MOVES = WIN_MATRIX.keys
  attr_reader :move

  def initialize(move)
    @move = move
  end

  def >(another_move)
    WIN_MATRIX[move].include?(another_move.move)
  end

  def <(another_move)
    WIN_MATRIX[another_move.move].include?(move)
  end

  def ==(another_move)
    move == another_move.move
  end

  def to_s
    move
  end
end

class Player
  include UXAmplifiers
  attr_reader :name, :choice
end

class Human < Player
  def initialize
    set_name
  end

  def set_name
    prompt("How would you like me to call you?")
    answer = gets.chomp

    if answer.strip.empty?
      answer = %w[Dovahkiin Neo Samus Rambo Achilles].sample.green
      puts "Alright, we will call you #{answer} then"
    else
      puts "Hello, #{answer.green}"
    end

    @name = answer.green
  end

  def move
    move = nil
    loop do
      prompt('Choose one - (r)ock, (p)aper, (sc)issors, (sp)ock, (l)izard')
      move = gets.chomp

      if move.strip.downcase == 's'
        puts "Enter 'sc' for scissors and 'sp' for Spock to differentiate"
        next
      end

      break if valid?(move.strip.downcase)

      puts "'#{move}' is not a valid move"
    end

    move = retrieve_actual(move.strip.downcase)
    @choice = Move.new(move)
  end

  private

  def valid?(move)
    return false if move.empty?
    Move::VALID_MOVES.any? { |valid_move| valid_move.start_with?(move) }
  end

  def retrieve_actual(move)
    Move::VALID_MOVES.each do |valid_move|
      return valid_move if valid_move.start_with?(move)
    end
  end
end

class Computer < Player
  COMPUTER_MATRIX = {
    'glados'    => Proc.new { Glados.new  },
    'pikachu'   => Proc.new { Pikachu.new },
    'yorha-2b'  => Proc.new { Yorha2B.new },
    'hal-9000'  => Proc.new { Hal9000.new },
    'alita'     => Proc.new { Alita.new   }
  }

  COMPUTERS = %w[(G)LaDOS (P)ikachu (Y)oRHa-2B (H)AL-9000 (A)lita]

  COMPUTER_PERSONALITIES = [
    'GLaDOS is sadistic and likes to hard counter your most favourite move',
    'Pikachu hates rocks, you know...after what happened with Onix',
    '2B has no battle plan as she has lost contact with HQ',
    'Hal is calm, intelligent, extremely rational and ALWAYS watching you',
    'Alita is Headstrong, emotionally driven and reacts to your last few moves'
  ]

  def move(_)
    @choice = Move.new(Move::VALID_MOVES.sample)
  end
end

class Glados < Computer
  def initialize
    @name = 'GLaDOS'.red
  end

  def move(human)
    human_mv_history = MoveHistory.instance.move_history[human.name]
    return super if human_mv_history.empty?

    frequent_mv = human_mv_history.max_by { |mv| human_mv_history.count(mv) }
    counter_mv = Move::LOSE_MATRIX[frequent_mv].sample

    @choice = Move.new(counter_mv)
  end
end

class Pikachu < Computer
  def initialize
    @name = 'Pikachu'.red
  end

  def move(_)
    sample_space = Move::LOSE_MATRIX['rock']
    @choice = Move.new(sample_space.sample)
  end
end

class Yorha2B < Computer
  def initialize
    @name = 'YoRHa-2B'.red
  end

  def move(_)
    @choice = Move.new(Move::VALID_MOVES.sample)
  end
end

class Hal9000 < Computer
  def initialize
    @name = 'HAL-9000'.red
  end

  def move(human)
    human_mv_history = MoveHistory.instance.move_history[human.name]
    return super if human_mv_history.empty?

    sample_space = human_mv_history.map do |move|
      Move::LOSE_MATRIX[move].sample
    end

    @choice = Move.new(sample_space.sample)
  end
end

class Alita < Computer
  def initialize
    @name = 'Alita'.red
  end

  def move(human)
    human_mv_history = MoveHistory.instance.move_history[human.name]
    return super if human_mv_history.empty?

    recent_mvs = human_mv_history.last(5)
    sample_space = recent_mvs.map do |move|
      Move::LOSE_MATRIX[move].sample
    end

    @choice = Move.new(sample_space.sample)
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

  def display_round_details
    width = 40
    puts "[ROUND - #{@round_number}]".center(width)
    puts formatted_scores.center(width)
    puts nil
  end

  def update_round_details(winner)
    @score[winner] += 1
    @round_number += 1
  end

  def display_scorecard
    puts formatted_scores
    display_divider
  end

  private

  def formatted_scores
    win_score = RPSSLGame::WIN_SCORE
    score_array = ["#{@human.name} - #{@score[:human]}/#{win_score}",
                   "#{@computer.name} - #{@score[:computer]}/#{win_score}",
                   "#{'Tie'.yellow} - #{@score[:tie]}"]
    score_array.join('  |  ')
  end
end

class RPSSLGame
  WIN_SCORE = 5
  include UXAmplifiers
  attr_reader :human, :computer, :scorecard

  def initialize
    display_welcome_message
  end

  def play
    @human = Human.new

    loop do
      choose_computer
      @scorecard = Scorecard.new(human, computer)

      play_rounds until game_won?
      display_game_winner_message

      break unless play_again?
    end

    display_goodbye_message
  end

  private

  def display_welcome_message
    display_clear_screen
    puts <<~welcome
    Let's play Rock Paper Scissors Spock Lizard
    I know it's daunting. Just choose one and cross your fingers
    The first to win #{"#{WIN_SCORE} ROUNDS".red.underline} is the grand winner
    welcome
    puts nil
  end

  def choose_computer
    display_comp_personality
    comp_choice = nil

    prompt("Who do you want to play against?")
    loop do
      prompt("Choose one - #{Computer::COMPUTERS.join(', ')}")
      comp_choice = gets.chomp

      break if valid?(comp_choice.strip.downcase)
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

  def valid?(comp_choice)
    return false if comp_choice.empty?
    Computer::COMPUTER_MATRIX.keys.any? { |comp| comp.start_with?(comp_choice) }
  end

  def retrieve_valid(comp_choice)
    Computer::COMPUTER_MATRIX.keys.each do |valids|
      return valids if valids.start_with?(comp_choice)
    end
  end

  def play_rounds
    display_clear_screen
    scorecard.display_round_details
    human.move
    computer.move(@human)
    update_move_history(@human, @computer)
    display_moves
    display_round_winner
    scorecard.update_round_details(who_won)
    scorecard.display_scorecard
    enter_to_continue unless game_won?
  end

  def update_move_history(human, computer)
    MoveHistory.instance.update_history(human.name, human.choice.move)
    MoveHistory.instance.update_history(computer.name, computer.choice.move)
  end

  def display_moves
    human_move = human.choice.move
    computer_move = computer.choice.move

    puts nil
    display_divider
    puts "#{human.name} chose #{human_move.green}; "\
         "#{computer.name} chose #{computer_move.red}"
  end

  def display_round_winner
    case who_won
    when :human    then puts "#{human.name} won!".green
    when :tie      then puts "It's a tie".yellow
    when :computer then puts "#{computer.name} won!".red
    end
  end

  def who_won
    if    human.choice < computer.choice then :computer
    elsif human.choice > computer.choice then :human
    else                                      :tie
    end
  end

  def game_won?
    player_score = scorecard.score[:human]
    computer_score = scorecard.score[:computer]

    player_score >= WIN_SCORE || computer_score >= WIN_SCORE
  end

  def display_game_winner_message
    puts nil
    if scorecard.score[:human] >= WIN_SCORE
      puts "#{human.name} is crowned as the champion"
    else
      puts "FATALITY! #{computer.name} is the undisputed champion"
    end
    puts nil
  end

  def display_goodbye_message
    puts nil
    puts "Thank you for playing RPSSL. See you again"
    puts nil
  end

  def play_again?
    play_again = nil
    prompt("Do you want to play again (y/n)")
    loop do
      play_again = gets.chomp
      break if %w[y n yes no].include?(play_again.downcase)
      prompt("Sorry, '#{play_again}' is invalid. Answer with y or n")
    end

    return true if %w[y yes].include?(play_again.downcase)
    false
  end
end

RPSSLGame.new.play
