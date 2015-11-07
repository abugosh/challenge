require 'line_of_credit/transaction'

module LineOfCredit

  # A line item on the transaction log representing a change in the balance value
  class BalanceTransaction < Transaction

    # Add the amount to the view's balance and update the day
    def update_view(view)
      LOCView.new(view.balance + @amount, view.interest, @day)
    end
  end
end
