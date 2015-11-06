require "./line_of_credit.rb"

RSpec.describe LineOfCredit do
  context "attributes" do
    let(:loc) { LineOfCredit.new(1000, 0.5) }

    it "should have a readable apr" do
      expect(loc.apr).to be_a(Float)
    end

    it "should have a readable credit_limit" do
      expect(loc.credit_limit).to be_a(Numeric)
    end

    it "should have a readable interest_total" do
      expect(loc.interest_total).to be_a(Float)
    end

    it "should have a readable balance" do
      expect(loc.balance).to be_a(Numeric)
    end

    context "sanity checks" do
      it "should make sure apr is a float" do
        expect{ LineOfCredit.new(1000, 10) }.to raise_error(TypeError)
        expect{ LineOfCredit.new(1000, "10") }.to raise_error(TypeError)
      end

      it "should make sure apr is positive" do
        expect{ LineOfCredit.new(1000, -10.0) }.to raise_error(ArgumentError)
      end

      it "should make sure credit_limit is numeric" do
        expect{ LineOfCredit.new("1000", 0.5) }.to raise_error(TypeError)
      end

      it "should make sure credit_limit is positive" do
        expect{ LineOfCredit.new(-1000, 0.5) }.to raise_error(ArgumentError)
      end
    end
  end

  context "#withdraw" do
    let(:loc) { LineOfCredit.new(1000, 0.35) }

    it "should let a user withdraw money and update the balance" do
      expect(loc.balance).to eq(0)

      loc.withdraw(500)

      expect(loc.balance).to eq(500)

      loc.withdraw(250)

      expect(loc.balance).to eq(750)
    end

    it "should not let a user withdraw more than the credit_limit" do
      expect{ loc.withdraw(5000000) }.to raise_error(InsufficentCreditError)
    end

    it "should not let the user withdraw when (balance + withdrawl) > credit_limit" do
      expect(loc.balance).to eq(0)

      loc.withdraw(500)

      expect(loc.balance).to eq(500)

      expect{ loc.withdraw(550) }.to raise_error(InsufficentCreditError)
    end

    it "should not let the user withdraw a negative number" do
      expect{ loc.withdraw(-500) }.to raise_error(ArgumentError)
    end
  end

  context "#pay" do
    let(:loc) {
      line = LineOfCredit.new(1000, 0.35)
      line.withdraw(500)
      line
    }

    it "should let the user pay down a balance" do
      expect(loc.balance).to eq(500)

      loc.pay(400)

      expect(loc.balance).to eq(100)
    end

    # This test will get changed to support interest later
    it "should not let the user make a payment more than balance" do
      expect{ loc.pay(600) }.to raise_error(InsufficentBalanceError)
    end

    it "should not let the user make a negative payment" do
      expect{ loc.pay(-500) }.to raise_error(ArgumentError)
    end
  end
end

RSpec.describe LOCView do
  context "attributes" do
    let(:view) { LOCView.new(0, 0, 0) }

    it "should have a balance" do
      expect(view.balance).to eq(0)
    end

    it "should have an interest" do
      expect(view.interest).to eq(0)
    end

    it "should have a day" do
      expect(view.day).to eq(0)
    end
  end
end

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
end

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

