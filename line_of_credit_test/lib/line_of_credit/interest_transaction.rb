require 'line_of_credit/transaction'

module LineOfCredit

  # A line item on the transaction log representing a change in the interest value
  class InterestTransaction < Transaction

    # Add the amount to the view's interest and update the day
    def update_view(view)
      LOCView.new(view.balance, view.interest + @amount, @day)
    end
  end
end
