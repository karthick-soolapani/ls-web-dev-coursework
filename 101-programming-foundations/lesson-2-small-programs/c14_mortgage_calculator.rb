# LS Course 101 - Programming Foundations
# Lesson 2 - Small Programs
# Chapter 14 - Assignment: Mortgage/Car Loan Calculator

# QUESTION
# m = p * (j / (1 - (1 + j)**(-n)))
# m -> monthly payment (to be calculated)
# p -> loan amount (given)
# j -> monthly interest rate (given)
# n -> loan duration in months (given)

def data_cleansing(data)
  # Removes extra spaces, commas, dollar sign etc.
  data = data.strip.split('')
  (data - [',', '%', ' ', '$']).join
end

def check_float(num)
  num = data_cleansing(num)
  # The regex checks for all possible numbers
  # Integer, float, positive/negative, trailing & leading decimals etc.
  if /\d/.match(num) && /^[+-]?\d*\.?\d*$/.match(num)
    if num.to_f.positive?
      'positive'
    elsif num.to_f.negative?
      'negative'
    else
      'zero'
    end
  else
    'invalid'
  end
end

def check_interger(num)
  num = data_cleansing(num)
  # Only positive case is needed. Added more granularity for future use
  if /^[+-]?\d+\.?0{0,}$/.match(num)
    if num.to_i.positive?
      'positive'
    elsif num.to_i.negative?
      'negative'
    else
      'zero'
    end
  else
    'invalid'
  end
end

def format_number(num)
  # First it restricts the number to 2 decimal places
  # Then it removes decimals if it's an integer
  num = format('%.2f', num)

  if num.to_f == num.to_i
    format('%g', num)
  else
    num
  end
end

def formatted_duration(duration)
  # Formatting the loan duration to enhance user experience
  num_years = Proc.new { |n| "#{n} year#{n == 1 ? '' : 's'}" }
  num_months = Proc.new { |n| "#{n} month#{n == 1 ? '' : 's'}" }

  duration_string = ''
  years = duration / 12
  months = duration % 12

  if years > 0
    duration_string << num_years.call(years)
    if months > 0
      duration_string << ' and '
    end
  end

  if months > 0
    duration_string << num_months.call(months)
  end
  duration_string
end

def prompt(message)
  puts "=> #{message}"
end

prompt('Welcome to Mortgage Calculator')
90.times { print '-' }
puts

loop do # main loop
  prompt('What is the loan amount?')
  prompt('Include only the number. e.g. $100,000.50 should be 100000.50')

  loan_amount = ''
  loop do # Loan Amount loop
    loan_amount = gets.chomp

    case check_float(loan_amount)
    when 'positive'
      break
    when 'zero'
      prompt('You want $0? Dream bigger. Provide a positive number')
    when 'negative'
      formatted_loan_amt = format_number(data_cleansing(loan_amount).to_f.abs)
      prompt('Wait...negative number? Are you giving money?')
      prompt("I can do that calulation too. "\
             "Do you want me to use $#{formatted_loan_amt}? (Y/N)")
      amount_response = gets.chomp
      break if amount_response.downcase.start_with?('y')
      prompt('Positive number please')
    when 'invalid'
      prompt("'#{loan_amount}' is not a valid number")
    end
  end

  loan_amount = data_cleansing(loan_amount).to_f.abs

  puts
  prompt('What is the annual rate of interest')
  prompt('Include only the number. e.g. 3.75% should be 3.75')

  interest_rate_annual = ''
  loop do # Interest Rate loop
    interest_rate_annual = gets.chomp

    case check_float(interest_rate_annual)
    when 'positive'
      break
    when 'zero'
      puts '0% interest? Sweet, you got yourself a nice deal'
      break
    when 'negative'
      prompt('Wait...negative interest? '\
             'You want the creditor to pay you interest?')
      prompt('Stop joking around. Positive number please')
    when 'invalid'
      prompt("'#{interest_rate_annual}' is not a valid number")
    end
  end

  interest_rate_annual = data_cleansing(interest_rate_annual).to_f
  interest_rate_monthly = interest_rate_annual / 12

  puts
  prompt('What is the loan duration in months?')
  prompt('Include only the number. e.g. 1.5 years should be 18')

  loan_duration_months = ''
  loop do # Loan Duration loop
    loan_duration_months = gets.chomp

    break if check_interger(loan_duration_months) == 'positive'

    prompt('Please provide a positive number without decimals')
  end

  loan_duration_months = data_cleansing(loan_duration_months).to_i
  loan_duration_formatted = formatted_duration(loan_duration_months)

  # Mortgage Calcualtion
  monthly_payment = if interest_rate_monthly == 0
                      loan_amount / loan_duration_months
                    else
                      loan_amount *
                        ((interest_rate_monthly / 100) / (1 - (1 +
                        (interest_rate_monthly / 100))**-loan_duration_months))
                    end

  total_payment = if interest_rate_monthly == 0
                    loan_amount
                  else
                    monthly_payment * loan_duration_months
                  end

  total_interest = if interest_rate_monthly == 0
                     0
                   else
                     total_payment - loan_amount
                   end

  90.times { print '-' }
  puts

  puts <<~loan_details
  Summary of the details provided by you -
  Loan Amount: $#{format_number(loan_amount)}
  Annual Rate of Interest: #{format_number(interest_rate_annual)}%
  Loan Duration: #{loan_duration_formatted}
  loan_details

  90.times { print '-' }
  puts

  puts <<~mortgage_details
  Mortgage details -
  Monthly Payment is $#{format_number(monthly_payment)}
  Total Payment (Principal + Interest) for the duration\
 #{loan_duration_formatted} is $#{format_number(total_payment)}
  Total Interest Payable for the duration #{loan_duration_formatted}\
 is $#{format_number(total_interest)}
  mortgage_details

  90.times { print '-' }
  puts

  prompt('Do you want to do another calculation? (Y/N)')
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end

puts 'Thanks for using the Calculator. Goodbye'
