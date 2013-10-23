module Hyperll
  class RegisterSet
    LOG2_BITS_PER_WORD = 6
    REGISTER_SIZE = 5
    INTEGER_SIZE = 32

    def initialize(count)
      @count = count

      @bits = count / LOG2_BITS_PER_WORD
      if @bits.zero?
        @size = 1
      elsif (@bits % INTEGER_SIZE).zero?
        @size = @bits
      else
        @size = @bits + 1
      end

      @values = Array.new(@size, 0)
    end

    def []=(position, value)
      bucket = position / LOG2_BITS_PER_WORD
      shift = REGISTER_SIZE * (position - (bucket * LOG2_BITS_PER_WORD))

      @values[bucket] = (@values[bucket] & ~(0x1f << shift)) | (value << shift)
    end

    def [](position)
      bucket = position / LOG2_BITS_PER_WORD
      shift = REGISTER_SIZE * (position - (bucket * LOG2_BITS_PER_WORD))

      return (@values[bucket] & (0x1f << shift)) >> shift
    end
  end
end
