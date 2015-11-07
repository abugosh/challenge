require 'line_of_credit/locview'

module LineOfCredit
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
end
