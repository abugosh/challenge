require 'line_of_credit/locview'
require 'line_of_credit/balance_transaction'
require 'line_of_credit/interest_transaction'

module LineOfCredit
  class InsufficentCreditError < StandardError
  end

  class InsufficentBalanceError < StandardError
  end

  class ContinuityError < StandardError
  end

  class LineOfCredit
    attr_reader :apr, :credit_limit

    def initialize(credit_limit, apr)
      raise TypeError, "credit_limit must be a Numeric" unless credit_limit.is_a? Numeric
      raise ArgumentError, "credit_limit must be positive" unless credit_limit >= 0
      @credit_limit = credit_limit

      raise TypeError, "apr must be a Float" unless apr.is_a? Float
      raise ArgumentError, "apr must be positive" unless apr >= 0
      @apr = apr

      @balance = 0

      @statement_open_index = 0
      @statement_base_view = LOCView.new(0, 0, 0)
      @transactions = [BalanceTransaction.new(0, 0)]
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

    def interest_total
      current_view.interest
    end

    def statement_open_day
      return 0 unless @transactions[@statement_open_index]

      @transactions[@statement_open_index].day
    end

    def close_statement(day)
      raise ContinuityError, "statement closing before current day" if day < current_day

      future_base_view = current_view

      view = @transactions[(@statement_open_index + 1)..@transactions.length].reduce(@statement_base_view) do |acc, trans|
        trans.compute_interest(acc, apr)
      end

      final_view = BalanceTransaction.new(0, day).compute_interest(view, apr)

      @transactions << InterestTransaction.new(final_view.interest - future_base_view.interest, day)

      @statement_base_view = future_base_view
      @statement_open_index = @transactions.length - 1
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
end
