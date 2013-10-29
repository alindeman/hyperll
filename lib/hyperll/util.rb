module Hyperll
  module Util
    INT_MASK = 0xFFFFFFFF
    POWERS_OF_TWO = 0.upto(32).map { |i| 2**i }.freeze
  end
end
