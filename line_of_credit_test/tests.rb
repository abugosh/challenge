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
end
