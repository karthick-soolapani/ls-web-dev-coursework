# LS Course 101 - Programming Foundations
# Lesson 5 - Advanced Ruby Collections
# Chapter 5 - Practice Problems, Question 6

# QUESTION
# Given this previously seen family hash, print out the name, age and gender of each family member:
# (Name) is a (age)-year-old (male or female).

$stdout.sync = true # To display output immediately on windows using git bash

munsters = {
  "Herman" => { "age" => 32, "gender" => "male" },
  "Lily" => { "age" => 30, "gender" => "female" },
  "Grandpa" => { "age" => 402, "gender" => "male" },
  "Eddie" => { "age" => 10, "gender" => "male" },
  "Marilyn" => { "age" => 23, "gender" => "female"}
}

munsters.each do |name, details|
  age = details['age']
  gender = details['gender']
  
  puts "#{name} is a #{age}-year-old #{gender}"
end
