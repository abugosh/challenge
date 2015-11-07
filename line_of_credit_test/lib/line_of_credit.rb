require 'line_of_credit/locview'
require 'line_of_credit/balance_transaction'
require 'line_of_credit/interest_transaction'

module LineOfCredit
  class InsufficentCreditError < StandardError
  end

  class InsufficentBalanceError < StandardError
  end

  # Errors regarding trying to do things in the past
  class ContinuityError < StandardError
  end

  # A model of a Line of Credit
  #
  # We made some assuptions with this class:
  #
  # * Transactions are going to come in order (reject transactions that come before the latest)
  # * We don't use dates (yet!), just day counts from account opening
  # * Statement periods do not close automatically (yet!)
  # * APRs and credit limits don't change
  # * We payoff interest before *any* principle
  class LineOfCredit
    attr_reader :apr, :credit_limit

    def initialize(credit_limit, apr)
      raise TypeError, "credit_limit must be a Numeric" unless credit_limit.is_a? Numeric
      raise ArgumentError, "credit_limit must be positive" unless credit_limit >= 0
      @credit_limit = credit_limit

      raise TypeError, "apr must be a Float" unless apr.is_a? Float
      raise ArgumentError, "apr must be positive" unless apr >= 0
      @apr = apr

      # For tracking which transaction opens the statement period
      @statement_open_index = 0

      # For caching a view of the transaction log at the open of the statement period
      @statement_open_view = LOCView.new(0, 0, 0)

      # The transaction log is a lot easier to reason about if it is primed with an empty transaction
      @transactions = [BalanceTransaction.new(0, 0)]
    end

    # We are assuming a payoff quote for the current day without taking into consideration the next interest calculation
    def payoff_quote
      balance + interest_total
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
      @transactions[@statement_open_index].day
    end

    def close_statement(day)
      raise ContinuityError, "statement closing before current day" if day < current_day

      # Compute the interest from all the transactions in the statement period
      view = @transactions[(@statement_open_index + 1)..@transactions.length].reduce(@statement_open_view) do |acc, trans|
        trans.compute_interest(acc, apr)
      end

      # Use a fake transaction to get the last stretch of interest
      final_view = BalanceTransaction.new(0, day).compute_interest(view, apr)

      # Now we append an InterestTransaction with the new interest (the interest calc to this point is cumulative)
      @transactions << InterestTransaction.new(final_view.interest - current_view.interest, day)

      @statement_open_view = current_view
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
      raise InsufficentBalanceError, "payment too large" if amount > payoff_quote
      raise ContinuityError, "withdrawal before current day" if day < current_day

      if interest_total > 0
        if interest_total > amount
          @transactions << InterestTransaction.new(-amount, day)
          amount = 0
        else
          amount -= interest_total
          @transactions << InterestTransaction.new(-interest_total, day)
        end
      end

      @transactions << BalanceTransaction.new(-amount, day) if amount > 0
    end

    private

    def current_view
      # Update the cached statement_open_view with the transactions from this statement period
      @transactions[(@statement_open_index + 1)..@transactions.length].reduce(@statement_open_view) do |view, trans|
        trans.update_view(view)
      end
    end
  end
end
