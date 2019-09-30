# LS Course 101 - Programming Foundations
# Lesson 5 - Advanced Ruby Collections
# Chapter 5 - Practice Problems, Question 11

# QUESTION
# Given the following data structure use a combination of methods, including
# either the select or reject method, to return a new array identical in structure
# to the original but containing only the integers that are multiples of 3.

$stdout.sync = true # To display output immediately on windows using git bash

arr = [[2], [3, 5, 7], [9], [11, 13, 15]]

arr_3_multiple = arr.map do |num_arr|
  num_arr.select do |num|
    num % 3 == 0
  end
end

p arr
p arr_3_multiple
