#! /usr/bin/env ruby

def factor(factors)
  out = {}
  data = factors.sort

  factors.each do |num|
    out[num] = []
  end

  data.each_with_index do |num, index|
    ((index + 1)...data.length).to_a.each do |x|
      out[data[x]] << num if data[x] % num == 0
    end
  end

  out
end
