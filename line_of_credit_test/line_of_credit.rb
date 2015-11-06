#! /usr/bin/env ruby

class InsufficentCreditError < StandardError
end

class InsufficentBalanceError < StandardError
end

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

  def withdraw(amount)
    raise ArgumentError, "cannot withdraw negative amounts" if amount < 0
    raise InsufficentCreditError, "withdrawal too large" if (amount + @balance) > @credit_limit
    @balance += amount
  end

  def pay(amount)
    raise ArgumentError, "cannot pay negative amounts" if amount < 0
    raise InsufficentBalanceError, "payment too large" if (@balance - amount) < 0
    @balance -= amount
  end
end

class LOCView
  attr_reader :balance, :interest, :day

  def initialize(balance, interest, day)
    @balance = balance
    @interest = interest
    @day = day
  end
end

class Transaction
  attr_reader :amount, :day

  def initialize(amount, day)
    @day = day
    @amount = amount
  end

  def update_view(view)
    raise NotImplementedError, "update_view not implemented"
  end
end

class BalanceTransaction < Transaction
end

class InterestTransaction < Transaction
end

