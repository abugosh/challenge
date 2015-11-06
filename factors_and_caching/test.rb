require './factor.rb'

RSpec.describe "the factoring method" do

  it "should return an empty hash for an empty array" do
    expect(factor([])).to eq({})
  end
end
