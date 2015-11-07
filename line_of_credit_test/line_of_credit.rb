#! /usr/bin/env ruby

class InsufficentCreditError < StandardError
end

class InsufficentBalanceError < StandardError
end

class ContinuityError < StandardError
end

class LineOfCredit
  attr_reader :apr, :credit_limit, :interest_total

  def initialize(credit_limit, apr)
    raise TypeError, "credit_limit must be a Numeric" unless credit_limit.is_a? Numeric
    raise ArgumentError, "credit_limit must be positive" unless credit_limit >= 0
    @credit_limit = credit_limit

    raise TypeError, "apr must be a Float" unless apr.is_a? Float
    raise ArgumentError, "apr must be positive" unless apr >= 0
    @apr = apr

    @interest_total = 0.0
    @balance = 0

    @transactions = []
  end

  def transaction_count
    @transactions.length
  end

  def balance
    current_view.balance
  end

  def current_day
    current_view.day
  end

  def withdraw(amount, day)
    raise ArgumentError, "cannot withdraw negative amounts" if amount < 0
    raise InsufficentCreditError, "withdrawal too large" if (amount + balance) > @credit_limit
    raise ContinuityError, "withdrawal before current day" if day < current_day

    @transactions << BalanceTransaction.new(amount, day)
  end

  def pay(amount, day)
    raise ArgumentError, "cannot pay negative amounts" if amount < 0
    raise InsufficentBalanceError, "payment too large" if (balance - amount) < 0
    raise ContinuityError, "withdrawal before current day" if day < current_day

    @transactions << BalanceTransaction.new(-amount, day)
  end

  private

  def current_view
    @transactions.reduce(LOCView.new(0, 0, 0)) do |view, trans|
      trans.update_view(view)
    end
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

  def compute_interest(view, apr)
    next_view = update_view(view)
    interest = (view.balance * (apr / 365) * (next_view.day - view.day)).round(2)

    LOCView.new(next_view.balance, next_view.interest + interest, next_view.day)
  end
end

class BalanceTransaction < Transaction
  def update_view(view)
    LOCView.new(view.balance + @amount, view.interest, @day)
  end
end

class InterestTransaction < Transaction
end

