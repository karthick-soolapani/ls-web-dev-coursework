# LS Course 101 - Programming Foundations
# Lesson 5 - Advanced Ruby Collections
# Chapter 5 - Practice Problems, Question 10

# QUESTION
# Given the following data structure and without modifying the original array,
# use the map method to return a new array identical in structure to the original
# but where the value of each integer is incremented by 1.

$stdout.sync = true # To display output immediately on windows using git bash

arr = [{a: 1}, {b: 2, c: 3}, {d: 4, e: 5, f: 6}]

arr_incremented = arr.map do |hash|
  hash.map do |key, value|
    [key, value + 1]
  end.to_h
end

p arr
p arr_incremented
