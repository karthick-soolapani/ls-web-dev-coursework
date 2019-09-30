# LS Course 101 - Programming Foundations
# Lesson 5 - Advanced Ruby Collections
# Chapter 5 - Practice Problems, Question 15

# QUESTION
# Given this data structure write some code to return an array which contains
# only the hashes where all the integers are even.

$stdout.sync = true # To display output immediately on windows using git bash

arr = [{a: [1, 2, 3]}, {b: [2, 4, 6], c: [3, 6], d: [4]}, {e: [8], f: [6, 10]}]

arr_filtered = arr.select do |hash|
  hash.all? do |_, value|
    value.all? { |num| num.even? }
  end
end

p arr
p arr_filtered
