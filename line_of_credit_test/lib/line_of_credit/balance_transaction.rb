require 'line_of_credit/transaction'

module LineOfCredit
  class BalanceTransaction < Transaction
    def update_view(view)
      LOCView.new(view.balance + @amount, view.interest, @day)
    end
  end
end
