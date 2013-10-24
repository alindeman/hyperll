module Hyperll
  class RegisterSet
    include Enumerable

    LOG2_BITS_PER_WORD = 6
    REGISTER_SIZE = 5
    INTEGER_SIZE = 32

    attr_reader :count, :size

    def initialize(count, values = nil)
      @count = count

      @bits = count / LOG2_BITS_PER_WORD
      if @bits.zero?
        @size = 1
      elsif (@bits % INTEGER_SIZE).zero?
        @size = @bits
      else
        @size = @bits + 1
      end

      @values = values || Array.new(@size, 0)
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

    def each
      return enum_for(:each) unless block_given?
      @count.times do |i|
        yield self[i]
      end
    end

    def update_if_greater(position, value)
      bucket = position / LOG2_BITS_PER_WORD
      shift = REGISTER_SIZE * (position - (bucket * LOG2_BITS_PER_WORD));
      mask = 0x1f << shift;

      current_value = @values[bucket] & mask
      new_value = value << shift
      if current_value < new_value
        @values[bucket] = (@values[bucket] & ~mask) | new_value
        true
      else
        false
      end
    end

    def merge(other)
      @size.times do |bucket|
        word = 0
        LOG2_BITS_PER_WORD.times do |j|
          mask = 0x1f << (REGISTER_SIZE * j);

          this_val = self.values[bucket] & mask
          other_val = other.values[bucket] & mask
          word |= [this_val, other_val].max
        end

        @values[bucket] = word
      end
    end

    def serialize
      @values.pack("N*")
    end

    protected
    def values
      @values
    end
  end
end
