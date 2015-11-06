#! /usr/bin/env ruby

def factor(factors)
  out = {}

  factors.each do |num|
    out[num] = []
  end

  factors.each do |num|
    out.keys.each do |key|
      unless num == key
        out[key] << num if key % num == 0
      end
    end
  end

  out
end
