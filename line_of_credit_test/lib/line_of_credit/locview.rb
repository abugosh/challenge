
module LineOfCredit

  # Running totals used as a view on the transaction log
  #
  # Immutable by design for ease of use. Mutability could be added for performance down the line.
  class LOCView
    attr_reader :balance, :interest, :day

    def initialize(balance, interest, day)
      @balance = balance
      @interest = interest.to_f
      @day = day
    end
  end
end
