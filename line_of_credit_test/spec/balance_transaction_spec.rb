require 'line_of_credit/balance_transaction'

module LineOfCredit
  RSpec.describe BalanceTransaction do
    context "#update_view" do
      let(:trans) { BalanceTransaction.new(100, 10) }
      let(:neg_trans) { BalanceTransaction.new(100, 10) }
      let(:view) { LOCView.new(0, 0, 0) }
      let(:started_view) { LOCView.new(400, 10, 3) }

      it "should update the view with the transaction data" do
        updated = trans.update_view(view)

        expect(view.balance).to eq(0)
        expect(view.day).to eq(0)
        expect(updated.balance).to eq(trans.amount)
        expect(updated.day).to eq(trans.day)
      end

      it "should update the view with the transaction data when its negative" do
        updated = neg_trans.update_view(view)

        expect(view.balance).to eq(0)
        expect(view.day).to eq(0)
        expect(updated.balance).to eq(neg_trans.amount)
        expect(updated.day).to eq(neg_trans.day)
      end

      it "should increment the balance and set the day" do
        updated = trans.update_view(started_view)

        expect(started_view.balance).to eq(400)
        expect(started_view.day).to eq(3)
        expect(updated.balance).to eq(trans.amount + started_view.balance)
        expect(updated.day).to eq(trans.day)
      end

      it "should not influence the interest" do
        updated = trans.update_view(view)
        started_updated = trans.update_view(started_view)

        expect(updated.interest).to eq(view.interest)
        expect(started_updated.interest).to eq(started_view.interest)
      end
    end
  end
end
