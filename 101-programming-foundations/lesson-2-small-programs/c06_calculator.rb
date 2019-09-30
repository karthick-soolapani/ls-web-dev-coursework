# LS Course 101 - Programming Foundations
# Lesson 2 - Small Programs
# Chapter 06 - Calculator

# QUESTION
# Ask the user for 2 numbers
# Ask the user for one operation - add, subtract, multiply, divide
# Perform the operation on these 2 numbers
# Display the result

puts "Hi, I'm your Adorable Calculator"
puts "Give me two numbers and I can perform some simple operations for you"
puts

print "What is the first number? "
num1 = gets.chomp.to_f
print "What is the second number? "
num2 = gets.chomp.to_f

puts "What operation would you like to perform?"
puts "---Type '1' for add"
puts "---Type '2' for subtract"
puts "---Type '3' for multiply"
puts "---Type '4' for divide"
operation = gets.chomp

case operation
when '1'
  answer = num1 + num2
  puts "Addition of #{num1} and #{num2} is #{answer}"
when '2'
  answer = num1 - num2
  puts "Subtraction of #{num2} from #{num1} is #{answer}"
when '3'
  answer = num1 * num2
  puts "Multiplication of #{num1} by #{num2} is #{answer}"
when '4'
  if num2 == 0
    puts "Asking me to divide by 0? Not cool"
  else
    answer = num1 / num2
    puts "Division of #{num1} by #{num2} is #{answer}"
  end
else
  puts "Go easy on me. Choose one of the four valid operators"
end
