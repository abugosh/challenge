require 'factor'

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

  it "should handle the case of a few primes and a few factorables" do
    numbers = [2, 3, 4, 6, 9]
    factored = factor(numbers)

    expect(factored[2]).to eq([])
    expect(factored[3]).to eq([])
    expect(factored[4]).to eq([2])
    expect(factored[6]).to eq([2, 3])
    expect(factored[9]).to eq([3])
  end

  it "should handle the sample case" do
    numbers = [10, 5, 2, 20]
    factored = factor(numbers)

    expect(factored).to eq({10 => [2, 5], 5 => [], 2 =>  [], 20 => [2,5,10]})
  end

  it "should handle repeats" do
    numbers = [2, 2, 2, 2, 4]

    factored = factor(numbers)

    expect(factored[2]).to eq([])
    expect(factored[4]).to eq([2])
  end

  it "should error on negative numbers" do
    numbers = [-2, 4]

    expect{ factor(numbers) }.to raise_error(ArgumentError)
  end

  it "should error on a zero factor" do
    numbers = [0, 4]

    expect{ factor(numbers) }.to raise_error(ArgumentError)
  end
end
