module Hyperll
  # Adapted from <https://github.com/addthis/stream-lib/blob/master/src/main/java/com/clearspring/analytics/hash/MurmurHash.java>
  class MurmurHash
    INT_MASK = 0xFFFFFFFF

    def self.hash(obj)
      if Integer === obj
        hash_int(obj)
      end
    end

    def self.hash_int(data)
      m = 0x5bd1e995
      r = 24

      h = 0

      k = (data * m) & INT_MASK
      k ^= k >> r
      h ^= (k * m) & INT_MASK

      k = ((data >> 32) * m) & INT_MASK
      k ^= k >> r
      h *= m
      h ^= k * m
      h &= INT_MASK

      h ^= h >> 13
      h *= m
      h &= INT_MASK
      h ^= h >> 15

      h & INT_MASK
    end
    private_class_method :hash_int
  end
end
