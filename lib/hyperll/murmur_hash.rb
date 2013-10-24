module Hyperll
  # Adapted from <https://github.com/addthis/stream-lib/blob/master/src/main/java/com/clearspring/analytics/hash/MurmurHash.java>
  class MurmurHash
    INT_MASK = 0xFFFFFFFF

    def self.hash(obj)
      if Integer === obj
        hash_int(obj)
      else
        hash_string(obj.to_s)
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

    def self.hash_string(str, seed = -1)
      data = str.bytes
      length = data.length

      m = 0x5bd1e995
      r = 24

      h = seed ^ length
      len_4 = length >> 2

      0.upto(len_4 - 1) do |i|
        i_4 = i << 2
        k = data[i_4 + 3]
        k = k << 8
        k = k | (data[i_4 + 2] & 0xff)
        k = k << 8
        k = k | (data[i_4 + 1] & 0xff)
        k = k << 8
        k = k | (data[i_4 + 0] & 0xff)
        k *= m
        k &= INT_MASK
        k ^= k >> r
        k *= m
        h *= m
        h ^= k
        h &= INT_MASK
      end

      len_m = len_4 << 2
      left = length - len_m

      if left != 0
        if left >= 3
          h ^= data[length - 3] << 16
        end
        if left >= 2
          h ^= data[length - 2] << 8
        end
        if left >= 1
          h ^= data[length - 1]
        end

        h *= m
        h &= INT_MASK
      end

      h ^= h >> 13
      h *= m
      h &= INT_MASK
      h ^= h >> 15

      h
    end
    private_class_method :hash_string
  end
end
