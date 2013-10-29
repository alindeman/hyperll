module Hyperll
  module Util
    INT_MASK = 0xFFFFFFFF
    POWERS_OF_TWO = 0.upto(32).map { |i| 2**i }.freeze

    def number_of_leading_zeros(x)
      return 32 if x == 0

      n = 0
      if x <= 0x0000FFFF
        n += 16
        x *= POWERS_OF_TWO[16]
      end

      if x <= 0x00FFFFFF
        n += 8;
        x *= POWERS_OF_TWO[8]
      end

      if x <= 0x0FFFFFFF
        n += 4
        x *= POWERS_OF_TWO[4]
      end

      if x <= 0x3FFFFFFF
        n += 2
        x *= POWERS_OF_TWO[2]
      end

      if x <= 0x7FFFFFFF
        n += 1
      end

      n
    end
  end
end
