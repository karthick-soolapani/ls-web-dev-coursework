# LS Course 101 - Programming Foundations
# Lesson 2 - Small Programs
# Chapter 10 - Refactoring Calculator

# QUESTION
# Ask the user for 2 numbers. Validate the numbers.
# Ask the user for one operation - add, subtract, multiply, divide.
# Validate the operation.
# Perform the operation on these 2 numbers.
# Display the result
# Ask if the user would like to perform another claculation

def prompt(message)
  puts "=> #{message}"
end

def valid_number?(num)
  num.to_i.to_s == num
end

def operation_to_message(op)
  case op
  when '1' then 'Adding'
  when '2' then 'Subtracting'
  when '3' then 'Multiplying'
  when '4' then 'Dividing'
  end
end

prompt("Welcome to Calculator! Enter your name:")

name = ''
loop do
  name = gets.chomp
  break unless name.empty?

  prompt("Make sure to use a valid name")
end

prompt("Hi #{name}!")

loop do # main loop
  num1 = ''
  loop do
    prompt("What is the first number?")
    num1 = gets.chomp

    break if valid_number?(num1)

    prompt("#{num1} isn't a valid number")
  end

  num2 = ''
  loop do
    prompt("What is the second number?")
    num2 = gets.chomp

    break if valid_number?(num2)

    prompt("#{num1} isn't a valid number")
  end

  operator_prompt = <<~MSG
    What operation would you like to perform?
    Enter '1' for add
    Enter '2' for subtract
    Enter '3' for multiply
    Enter '4' for division
  MSG

  prompt(operator_prompt)

  operator = ''
  loop do
    operator = gets.chomp

    break if %w(1 2 3 4).include?(operator)

    puts "Must choose only 1, 2, 3 or 4"
  end

  prompt("#{operation_to_message(operator)} the two numbers...")

  result = case operator
           when '1'
             num1.to_f + num2.to_f
           when '2'
             num1.to_f - num2.to_f
           when '3'
             num1.to_f * num2.to_f
           when '4'
             num1.to_f / num2.to_f
           end

  if num2.to_f == 0
    puts "Asking me to divide by 0? Not cool"
  else
    puts "Here you go: #{result}"
  end

  prompt("Do you want to perform another calculation? (Y/N)")
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end

puts "See you again"
