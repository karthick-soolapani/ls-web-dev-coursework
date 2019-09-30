# LS Course 101 - Programming Foundations
# Lesson 5 - Advanced Ruby Collections
# Chapter 5 - Practice Problems, Question 4

# QUESTION
# For each of these collection objects where the value 3 occurs, demonstrate how you would change this to 4.

$stdout.sync = true # To display output immediately on windows using git bash

arr1 = [1, [2, 3], 4]
p arr1
arr1[1][1] = 4
p arr1

arr2 = [{a: 1}, {b: 2, c: [7, 6, 5], d: 4}, 3]
p arr2
arr2[2] = 4
p arr2

hsh1 = {first: [1, 2, [3]]}
p hsh1
hsh1[:first][2][0] = 4
p hsh1

hsh2 = {['a'] => {a: ['1', :two, 3], b: 4}, 'b' => 5}
p hsh2
hsh2[['a']][:a][2] = 4
p hsh2
