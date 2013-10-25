module Hyperll
  class HyperLogLogPlus
    # Constructs a new HyperLogLogPlus instance
    #
    # p - precision value for the normal set
    # sp - precision value for the sparse set
    #
    # 4 <= p <= sp < 32
    def initialize(p, sp = 0)
      raise ArgumentError, "p must be >= 4" if p < 4
      raise ArgumentError, "sp must be < 32" if sp >= 32
      raise ArgumentError, "p must be <= sp" if !sp.zero? && p > sp

      @p, @sp = p, sp
    end
  end
end
