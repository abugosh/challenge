#! /usr/bin/env ruby

class LineOfCredit
  attr_reader :apr, :credit_limit, :interest_total, :balance

  def initialize(credit_limit, apr)
    raise TypeError, "credit_limit must be a Numeric" unless credit_limit.is_a? Numeric
    raise ArgumentError, "credit_limit must be positive" unless credit_limit >= 0
    @credit_limit = credit_limit

    raise TypeError, "apr must be a Float" unless apr.is_a? Float
    raise ArgumentError, "apr must be positive" unless apr >= 0
    @apr = apr

    @interest_total = 0.0
    @balance = 0
  end
end
