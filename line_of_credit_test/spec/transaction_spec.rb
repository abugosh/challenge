require 'line_of_credit'

RSpec.describe Transaction do
  context "attributes" do
    let(:trans) { Transaction.new(100, 0) }

    it "should have a day" do
      expect(trans.day).to eq(0)
    end

    it "should have an amount" do
      expect(trans.amount).to eq(100)
    end
  end

  context "#update_view" do
    let(:trans) { Transaction.new(100, 0) }
    let(:view) { LOCView.new(0, 0, 0) }

    it "should throw an error" do
      expect{ trans.update_view(view) }.to raise_error(NotImplementedError)
    end
  end

  context "#compute_interest" do
    it "should return an updated_view with an updated interest value" do
      trans = BalanceTransaction.new(0, 30)
      view = LOCView.new(500, 0, 0)
      updated = trans.compute_interest(view, 0.35)

      expect(updated.interest).to eq(14.38)
    end

    it "should return an updated_view with an updated interest value" do
      trans = BalanceTransaction.new(0, 60)
      view = LOCView.new(500, 0, 30)
      updated = trans.compute_interest(view, 0.35)

      expect(updated.interest).to eq(14.38)
    end

    it "should work for our other scenario example" do
      transactions = [BalanceTransaction.new(500, 0),
                      BalanceTransaction.new(-200, 15),
                      BalanceTransaction.new(100, 25),
                      BalanceTransaction.new(0, 30)]

      updated = transactions.reduce(LOCView.new(0,0,0)) do |acc, trans|
        trans.compute_interest(acc, 0.35)
      end

      expect(updated.interest).to eq(11.99)
    end
  end
end
