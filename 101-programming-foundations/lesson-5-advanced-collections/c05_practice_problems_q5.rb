# LS Course 101 - Programming Foundations
# Lesson 5 - Advanced Ruby Collections
# Chapter 5 - Practice Problems, Question 5

# QUESTION
# figure out the total age of just the male members of the family.

$stdout.sync = true # To display output immediately on windows using git bash

munsters = {
  "Herman" => { "age" => 32, "gender" => "male" },
  "Lily" => { "age" => 30, "gender" => "female" },
  "Grandpa" => { "age" => 402, "gender" => "male" },
  "Eddie" => { "age" => 10, "gender" => "male" },
  "Marilyn" => { "age" => 23, "gender" => "female"}
}

total_age = 0

munsters.each_value { |details| total_age += details['age'] if details['gender'] == 'male' }

puts "Total age of the male members of the munsters family is #{total_age}"
