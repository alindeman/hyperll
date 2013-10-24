require_relative 'register_set'
require_relative 'murmur_hash'

module Hyperll
  class HyperLogLog
    INT_SIZE = 32
    INT_HASH = 0xFFFFFFFF

    attr_reader :log2m

    # Constructs a new HyperLogLog instance
    #
    # log2m - accuracy of the counter; larger values are more accurate
    def initialize(log2m)
      @log2m = log2m
      @count = 2 ** log2m
      @register_set = RegisterSet.new(@count)

      case log2m
      when 4
        @alphaMM = 0.673 * @count * @count
      when 5
        @alphaMM = 0.697 * @count * @count
      when 6
        @alphaMM = 0.709 * @count * @count
      else
        @alphaMM = (0.7213 / (1 + 1.079 / @count)) * @count * @count
      end
    end

    def offer(obj)
      offer_hashed(MurmurHash.hash(obj))
    end

    def offer_hashed(value)
      j = value >> (INT_SIZE - @log2m)
      r = number_of_leading_zeros(((value << @log2m) & INT_HASH) | (1 << (@log2m - 1)) + 1) + 1
      @register_set.update_if_greater(j, r)
    end

    def cardinality
      register_sum = 0.0
      zeros = 0.0
      @register_set.each do |value|
        register_sum += 1.0 / (1 << value)
        zeros += 1 if value == 0
      end

      estimate = @alphaMM * (1 / register_sum)
      if estimate <= (5.0 / 2.0) * @count
        # small range estimate
        (@count * Math.log(@count / zeros)).round
      else
        estimate.round
      end
    end

    def merge(*others)
      raise "Cannot merge hyperloglogs of different sizes" unless others.all? { |o| o.log2m == log2m }

      others.each do |other|
        @register_set.merge(other.register_set)
      end

      self
    end

    protected
    def number_of_leading_zeros(int)
      -(Math.log2(int).to_i - 31)
    end

    def register_set
      @register_set
    end
  end
end
