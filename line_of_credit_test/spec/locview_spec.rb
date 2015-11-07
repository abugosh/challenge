require 'line_of_credit'

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
