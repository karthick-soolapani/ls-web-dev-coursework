# LS Course 101 - Programming Foundations
# Lesson 2 - Small Programs
# Chapter 19 - Rock Paper Scissors Game

# QUESTION
# The user makes a choice
# The computer makes a choice
# The winner is displayed

$stdout.sync = true

def prompt(message)
  puts "=> #{message}"
end

def result(player, computer)
  if (CHOICE_TO_COMPARE.index(computer) - VALID_CHOICES.index(player)) == 1
    'You lose!'
  elsif player == computer
    "It's a tie"
  else
    'You win!'
  end
end

VALID_CHOICES = %w(rock paper scissor)
CHOICE_TO_COMPARE = %w(dummy paper scissor rock)

puts "Let's play Rock Paper Scissor"

loop do
  player_choice = ''
  loop do
    prompt("Choose one of the following: #{VALID_CHOICES.join(', ')}")
    player_choice = gets.chomp

    break if VALID_CHOICES.include?(player_choice.downcase)

    puts "#{player_choice} is not a valid choice"
  end

  player_choice.downcase!
  computer_choice = VALID_CHOICES.sample

  result = result(player_choice, computer_choice)
  puts "You chose #{player_choice}; computer chose #{computer_choice}"
  puts "Result: #{result}"

  prompt('Do you want to play again? (Y/N)')
  play_again = gets.chomp

  break unless play_again.downcase.start_with?('y')  
end

puts 'See you again'
