require './factor.rb'

RSpec.describe "the factoring method" do

  it "should return an empty hash for an empty array" do
    expect(factor([])).to eq({})
  end

  it "should return a key in the hash for each value in the array" do
    numbers = [1,2,3,4,5]

    expect(factor(numbers).keys).to eq(numbers)
  end

  it "should give empty factor arrays for prime factors" do
    numbers = [2,3,5,7,11,13]
    factored = factor(numbers)

    numbers.each do |num|
      expect(factored[num]).to eq([])
    end
  end

  it "should handle the case of a prime and a factorable" do
    numbers = [2, 4]
    factored = factor(numbers)

    expect(factored[2]).to eq([])
    expect(factored[4]).to eq([2])
  end
end
