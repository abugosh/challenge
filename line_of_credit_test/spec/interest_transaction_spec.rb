require 'line_of_credit/interest_transaction'

module LineOfCredit
  RSpec.describe InterestTransaction do
    context "#update_view" do
      let(:trans) { InterestTransaction.new(100, 10) }
      let(:neg_trans) { InterestTransaction.new(100, 10) }
      let(:view) { LOCView.new(0, 0, 0) }
      let(:started_view) { LOCView.new(400, 10, 3) }

      it "should update the view with the transaction data" do
        updated = trans.update_view(view)

        expect(view.interest).to eq(0)
        expect(view.day).to eq(0)
        expect(updated.interest).to eq(trans.amount)
        expect(updated.day).to eq(trans.day)
      end

      it "should update the view with the transaction data when its negative" do
        updated = neg_trans.update_view(view)

        expect(view.interest).to eq(0)
        expect(view.day).to eq(0)
        expect(updated.interest).to eq(neg_trans.amount)
        expect(updated.day).to eq(neg_trans.day)
      end

      it "should increment the interest and set the day" do
        updated = trans.update_view(started_view)

        expect(started_view.interest).to eq(10)
        expect(started_view.day).to eq(3)
        expect(updated.interest).to eq(trans.amount + started_view.interest)
        expect(updated.day).to eq(trans.day)
      end

      it "should not influence the balance" do
        updated = trans.update_view(view)
        started_updated = trans.update_view(started_view)

        expect(updated.balance).to eq(view.balance)
        expect(started_updated.balance).to eq(started_view.balance)
      end
    end
  end
end
