# LS Course 101 - Programming Foundations
# Lesson 5 - Advanced Ruby Collections
# Chapter 5 - Practice Problems, Question 9

# QUESTION
# Given this data structure, return a new array of the same structure but with the
# sub arrays being ordered (alphabetically or numerically as appropriate) in descending order.

$stdout.sync = true # To display output immediately on windows using git bash

arr = [['b', 'c', 'a'], [2, 1, 3], ['blue', 'black', 'green']]

arr_sorted = arr.map do |sub_arr|
  sub_arr.sort.reverse
end

p arr
p arr_sorted
