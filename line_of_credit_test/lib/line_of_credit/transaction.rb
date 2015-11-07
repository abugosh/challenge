require 'line_of_credit/locview'

module LineOfCredit

  # A base class for transactions
  #
  # Transactions are immutable to make them easier to reason about.
  class Transaction
    attr_reader :amount, :day

    def initialize(amount, day)
      @day = day
      @amount = amount
    end

    # This should return an updated LOCView, at a minimum it should update the day
    def update_view(view)
      raise NotImplementedError, "update_view not implemented"
    end

    def compute_interest(view, apr)
      next_view = update_view(view)

      # The interest transaction
      # We round to 2 decimal places because we aren't using a Money library (yet!)
      interest = (view.balance * (apr / 365) * (next_view.day - view.day)).round(2)

      LOCView.new(next_view.balance, next_view.interest + interest, next_view.day)
    end
  end
end
