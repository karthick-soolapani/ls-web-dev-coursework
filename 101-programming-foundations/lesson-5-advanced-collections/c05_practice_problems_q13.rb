# LS Course 101 - Programming Foundations
# Lesson 5 - Advanced Ruby Collections
# Chapter 5 - Practice Problems, Question 13

# QUESTION
# Given the following data structure, return a new array containing the same
# sub-arrays as the original but ordered logically according to the numeric
# value of the odd integers they contain.
# example of sorted array - [[1, 8, 3], [1, 6, 7], [1, 4, 9]]

$stdout.sync = true # To display output immediately on windows using git bash

arr = [[1, 6, 7], [1, 4, 9], [1, 8, 3]]

arr_sorted = arr.sort_by do |sub_arr|
  sort_value = 0
  sub_arr.each do |num|
    sort_value += num if num.odd?
  end
  sort_value
end

p arr
p arr_sorted
