require 'line_of_credit'

module LineOfCredit
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

    context "#transaction_count" do
      let(:loc) { LineOfCredit.new(1000, 0.35) }

      it "should start at one" do
        expect(loc.transaction_count).to eq(1)
      end

      it "should increase by 1 for a withdrawal" do
        loc.withdraw(500, 0)

        expect(loc.transaction_count).to eq(2)
      end

      it "should increase by 1 for a pay" do
        loc.withdraw(500, 0)
        loc.pay(200, 0)

        expect(loc.transaction_count).to eq(3)
      end

      it "should increase by 1 for a close_statement" do
        loc.close_statement(30)

        expect(loc.transaction_count).to eq(2)
      end
    end

    context "#current_day" do
      let(:loc) { LineOfCredit.new(1000, 0.35) }

      it "should start at zero" do
        expect(loc.current_day).to eq(0)
      end

      it "should set itself to the next withdrawal day" do
        loc.withdraw(500, 5)

        expect(loc.current_day).to eq(5)
      end

      it "should set itself to the next payment day" do
        loc.withdraw(500, 5)
        loc.pay(200, 10)

        expect(loc.current_day).to eq(10)
      end
    end

    context "#statement_open_day" do
      let(:loc) { LineOfCredit.new(1000, 0.35) }

      it "should start at zero" do
        expect(loc.statement_open_day).to eq(0)
      end

      it "shouldn't be updated by transactions" do
        loc.withdraw(500, 15)

        expect(loc.statement_open_day).to eq(0)
      end

      it "should be updated by last close_statement" do
        loc.close_statement(30)

        expect(loc.statement_open_day).to eq(30)
      end
    end

    context "#close_statement" do
      let(:loc) { LineOfCredit.new(1000, 0.35) }

      it "should add interest" do
        loc.withdraw(500, 0)

        loc.close_statement(30)

        expect(loc.interest_total).to eq(14.38)
      end

      it "should work multiple times" do
        loc.withdraw(500, 0)

        loc.close_statement(30)

        expect(loc.interest_total).to eq(14.38)

        loc.close_statement(60)

        expect(loc.interest_total).to be_within(0.01).of(14.38 * 2)
      end

      it "should not let you close a statement in the past" do
        loc.withdraw(500, 35)

        expect{ loc.close_statement(30) }.to raise_error(ContinuityError)
      end
    end

    context "#withdraw" do
      let(:loc) { LineOfCredit.new(1000, 0.35) }

      it "should let a user withdraw money and update the balance" do
        expect(loc.balance).to eq(0)

        loc.withdraw(500, 0)

        expect(loc.balance).to eq(500)

        loc.withdraw(250, 0)

        expect(loc.balance).to eq(750)
      end

      it "should not let a user withdraw more than the credit_limit" do
        expect{ loc.withdraw(5000000, 0) }.to raise_error(InsufficentCreditError)
      end

      it "should not let the user withdraw when (balance + withdrawl) > credit_limit" do
        expect(loc.balance).to eq(0)

        loc.withdraw(500, 0)

        expect(loc.balance).to eq(500)

        expect{ loc.withdraw(550, 0) }.to raise_error(InsufficentCreditError)
      end

      it "should not let the user withdraw a negative number" do
        expect{ loc.withdraw(-500, 0) }.to raise_error(ArgumentError)
      end

      it "should not let a user withdraw from the past" do
        loc.withdraw(500, 10)

        expect{ loc.withdraw(100, 5) }.to raise_error(ContinuityError)
      end
    end

    context "#pay" do
      let(:loc) {
        line = LineOfCredit.new(1000, 0.35)
        line.withdraw(500, 0)
        line
      }

      it "should let the user pay down a balance" do
        expect(loc.balance).to eq(500)

        loc.pay(400, 0)

        expect(loc.balance).to eq(100)
      end

      # This test will get changed to support interest later
      it "should not let the user make a payment more than balance" do
        expect{ loc.pay(600, 0) }.to raise_error(InsufficentBalanceError)
      end

      it "should not let the user make a negative payment" do
        expect{ loc.pay(-500, 0) }.to raise_error(ArgumentError)
      end

      it "should not let a user pay from the past" do
        loc.withdraw(100, 10)

        expect{ loc.pay(100, 5) }.to raise_error(ContinuityError)
      end
    end
  end
end
