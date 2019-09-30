**LS Course 101 - Programming Foundations  
Lesson 2 - Small Programs  
Chapter 07 - Pseudo-code**<br><br>


## QUESTION 1

Write pseudo-code (casual and formal) for a method that returns the sum of two integers

#### CASUAL FORMAT

```
Given 2 integers

Create a method that accepts 2 integers
Add the two integers
Return the value
```

#### FORMAL FORMAT

```
START

# Given 2 integers - num1, num2

SET sum_of_2 = method with 2 parameters
SET sum = num1 + num2
PRINT sum

END
```
<br>

## QUESTION 2

Write pseudo-code (casual and formal) for a method that takes an array of strings, and returns a string that is all those strings concatenated together

#### CASUAL FORMAT

```
Given an array of strings

Iterate through the collection one by one
  - Add the element from the current iteration to a newly initialized string, joined_string
  - Move to the next iteration and repeat the above process until the end of collection is reached

Return the joined_string
```

#### FORMAL FORMAT

```
START

# Given a collection of strings called string_collection

SET iterator = 0
SET joined_string = ''

WHILE iterator < length of string_collection
  - SET str = element from the current iteration
  - joined_string = joined_string + str
  - iterator = iterator + 1

PRINT joined_string 

END
```
<br>

## QUESTION 3

Write pseudo-code (casual and formal) for a method that takes an array of integers, and returns a new array with every other element

#### CASUAL FORMAT

```
Given an array of integers

Iterate through the collection one by one
  - If the current iteration is even
    - add the element from current iteration to a new array, alternates
  - Otherwise, if the current iteration is odd
    - move to the next iteration

Return the alternates array
```

#### FORMAL FORMAT

```
START

# Given a collection of integers called number_array

SET iteration = 0
SET alternates = []

WHILE iteration < length of number_array
  - SET num = element from the current iteration
  - alternates.push(num)
  - iteration = iteration + 2

PRINT alternates array

END
```
