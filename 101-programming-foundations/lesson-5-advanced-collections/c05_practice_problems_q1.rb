# LS Course 101 - Programming Foundations
# Lesson 5 - Advanced Ruby Collections
# Chapter 5 - Practice Problems, Question 1

# QUESTION
# How would you order this array of number strings by descending numeric value?

$stdout.sync = true # To display output immediately on windows using git bash

arr = ['10', '11', '9', '7', '8']

arr_sorted = arr.sort {|a, b| b.to_i <=> a.to_i}
p arr_sorted

arr_sorted_v2 = arr.sort_by {|num| -num.to_i}
p arr_sorted_v2
