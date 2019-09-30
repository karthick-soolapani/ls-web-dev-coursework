# LS Course 101 - Programming Foundations
# Lesson 5 - Advanced Ruby Collections
# Chapter 5 - Practice Problems, Question 8

# QUESTION
# Using the each method, write some code to output all of the vowels from the strings.

$stdout.sync = true # To display output immediately on windows using git bash

VOWEL = 'aeiou'
hsh = {first: ['the', 'quick'], second: ['brown', 'fox'], third: ['jumped'], fourth: ['over', 'the', 'lazy', 'dog']}

hsh.each_value do |words|
  words.each do |word|
    word.each_char do |char|
      print char if VOWEL.include?(char)
    end
    puts
  end
end

