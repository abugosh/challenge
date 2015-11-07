
module LineOfCredit
  class LOCView
    attr_reader :balance, :interest, :day

    def initialize(balance, interest, day)
      @balance = balance
      @interest = interest.to_f
      @day = day
    end
  end
end
