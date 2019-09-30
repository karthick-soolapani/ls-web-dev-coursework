# LS Course 101 - Programming Foundations
# Lesson 5 - Advanced Ruby Collections
# Chapter 5 - Practice Problems, Question 2

# QUESTION
# How would you order this array of hashes based on the year of publication
# of each book, from the earliest to the latest?

$stdout.sync = true # To display output immediately on windows using git bash

books = [
  {title: 'One Hundred Years of Solitude', author: 'Gabriel Garcia Marquez', published: '1967'},
  {title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', published: '1925'},
  {title: 'War and Peace', author: 'Leo Tolstoy', published: '1869'},
  {title: 'Ulysses', author: 'James Joyce', published: '1922'}
]

books_sorted = books.sort_by { |book| book[:published] }

p books
p books_sorted

books_sorted_desc = books.sort { |book_1, book_2| book_2[:published] <=> book_1[:published] }

p books_sorted_desc
