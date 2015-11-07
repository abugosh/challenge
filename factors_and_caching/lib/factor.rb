#! /usr/bin/env ruby

# Takes an array of postive non-zero integers and returns a hash of where each number is a key to its factors from the input array
def factor(factors)
  out = {}
  # Short circut the method if factors is empty
  return out if factors.empty?

  # Uniqify and sort to cut down on calculations
  sorted_factors = factors.uniq.sort

  # Negative factors are more complicated http://math.stackexchange.com/questions/404783/negative-factors-of-a-number
  raise ArgumentError, "only doing simple factorization" if sorted_factors.first < 0
  raise ArgumentError, "can't factor with 0" if sorted_factors.first == 0

  # prepare the output hash
  sorted_factors.each do |num|
    out[num] = []
  end

  # Iterate over the factors and compare each one to all factors greater than it
  sorted_factors.each_with_index do |factor, index|
    sorted_factors[(index + 1)..sorted_factors.length].each do |num|
      out[num] << factor if num % factor == 0
    end
  end

  out
end
