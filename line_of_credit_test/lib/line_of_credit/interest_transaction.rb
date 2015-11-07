require 'line_of_credit/transaction'

module LineOfCredit
  class InterestTransaction < Transaction
    def update_view(view)
      LOCView.new(view.balance, view.interest + @amount, @day)
    end
  end
end
