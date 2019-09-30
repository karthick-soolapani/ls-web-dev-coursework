# LS Course 101 - Programming Foundations
# Lesson 5 - Advanced Ruby Collections
# Chapter 5 - Practice Problems, Question 16

# QUESTION
# Each UUID consists of 32 hexadecimal characters, and is typically broken into
# 5 sections like this 8-4-4-4-12 and represented as a string.
# It looks like this: "f65c57f6-a6aa-17a8-faa1-a67f2dc9fa91"
# Write a method that returns one UUID when called with no parameters.

$stdout.sync = true # To display output immediately on windows using git bash

def generate_uuid
  hexadecimals = []
  (0..9).each { |digit| hexadecimals << digit.to_s }
  ('a'..'f').each { |digit| hexadecimals << digit }
  dashes_position = [8, 12, 16, 20]
  
  uuid = ''
  uuid_counter = 0
  
  while uuid_counter < 32
    uuid << hexadecimals.sample
    
    uuid_counter += 1
    uuid << '-' if dashes_position.include?(uuid_counter)
  end
  uuid
end

puts generate_uuid
puts generate_uuid
puts generate_uuid
puts generate_uuid
