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
