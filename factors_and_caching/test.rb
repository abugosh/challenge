require './factor.rb'

RSpec.describe "the factoring method" do

  it "should return an empty hash for an empty array" do
    expect(factor([])).to eq({})
  end

  it "should return a key in the hash for each value in the array" do
    numbers = [1,2,3,4,5]

    expect(factor(numbers).keys).to eq(numbers)
  end
end
