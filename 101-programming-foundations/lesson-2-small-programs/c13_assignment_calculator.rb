# LS Course 101 - Programming Foundations
# Lesson 2 - Small Programs
# Chapter 13 - Optional Assignment: Calculator Bonus Features

# QUESTION
# Ask the user for 2 numbers. Validate the numbers.
# Ask the user for one operation - add, subtract, multiply, divide.
# Validate the operation.
# Perform the operation on these 2 numbers.
# Display the result
# Ask if the user would like to perform another claculation

require 'yaml'

LANGUAGE = 'en'
MESSAGES = YAML.load_file('c13_calculator_messages.yml')

def actual_message(key, lang='en')
  MESSAGES[lang][key]
end

def prompt(key)
  message = actual_message(key, LANGUAGE)
  puts "=> #{message}"
end

def prompt_with_prefix(key, opt_message)
  message = actual_message(key, LANGUAGE)
  phrase = ''

  opt_message.each { |msg| phrase << msg + ' ' }
  phrase << message
  puts "=> #{phrase}"
end

def prompt_with_suffix(key, opt_message)
  message = actual_message(key, LANGUAGE)
  phrase = '' + message

  opt_message.each { |msg| phrase << ' ' + msg }
  puts "=> #{phrase}"
end

def valid_number?(num)
  Float(num)
rescue ArgumentError
  false
end

def operation_to_message(op)
  case op
  when '1' then 'adding_confirmation'
  when '2' then 'subtracting_confirmation'
  when '3' then 'multiplying_confirmation'
  when '4' then 'dividing_confirmation'
  end
end

prompt('welcome')

name = ''
loop do
  name = gets.chomp
  break unless name.empty?

  prompt('invalid_name')
end

prompt_with_suffix('greeting', [name, '!'])

loop do # main loop
  num1 = ''
  loop do
    prompt('first_number')
    num1 = gets.chomp

    break if valid_number?(num1)

    prompt_with_prefix('invalid_number', ["'#{num1}'"])
  end

  num2 = ''
  loop do
    prompt('second_number')
    num2 = gets.chomp

    break if valid_number?(num2)

    prompt_with_prefix('invalid_number', ["'#{num2}'"])
  end

  prompt('operations_list')

  operator = ''
  loop do
    operator = gets.chomp

    break if %w(1 2 3 4).include?(operator)

    prompt('invalid_operator')
  end

  prompt(operation_to_message(operator))

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
  if (operator == '4') && (num2.to_f == 0)
    prompt('zero_division')
  elsif result.to_i == result
    prompt_with_suffix('result', [result.to_i.to_s])
  else
    prompt_with_suffix('result', [result.to_s])
  end

  prompt('another_calc')
  answer = gets.chomp
  break unless answer.downcase.start_with?(actual_message('another_calc_ans'))
end

prompt('goodbye')
