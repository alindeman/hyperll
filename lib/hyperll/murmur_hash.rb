module Hyperll
  # Adapted from <https://github.com/addthis/stream-lib/blob/master/src/main/java/com/clearspring/analytics/hash/MurmurHash.java>
  class MurmurHash
    INT_MASK  = 0xFFFFFFFF
    LONG_MASK = 0xFFFFFFFFFFFFFFFF

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
      data = str.bytes.to_a
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

    def self.hash64(obj)
      return hash64_str(obj.to_s)
    end

    def self.hash64_str(str, seed = 0xe17a1465)
      data = str.bytes.to_a
      length = data.length

      m = 0xc6a4a7935bd1e995
      r = 47

      h = (seed & 0xffffffff) ^ (length * m)
      length8 = length / 8

      0.upto(length8 - 1) { |i|
        i8 = i * 8
        k = ((data[i8 + 0] & 0xff))       + ((data[i8 + 1] & 0xff) << 8)  +
            ((data[i8 + 2] & 0xff) << 16) + ((data[i8 + 3] & 0xff) << 24) +
            ((data[i8 + 4] & 0xff) << 32) + ((data[i8 + 5] & 0xff) << 40) +
            ((data[i8 + 6] & 0xff) << 48) + ((data[i8 + 7] & 0xff) << 56)

        k *= m
        k &= LONG_MASK
        k ^= k >> r
        k *= m

        h ^= k
        h *= m
        h &= LONG_MASK
      }

      left = length % 8
      if left >= 7 then h ^= (data[(length & ~7) + 6] & 0xff) << 48 end
      if left >= 6 then h ^= (data[(length & ~7) + 5] & 0xff) << 40 end
      if left >= 5 then h ^= (data[(length & ~7) + 4] & 0xff) << 32 end
      if left >= 4 then h ^= (data[(length & ~7) + 3] & 0xff) << 24 end
      if left >= 3 then h ^= (data[(length & ~7) + 2] & 0xff) << 16 end
      if left >= 2 then h ^= (data[(length & ~7) + 1] & 0xff) << 8  end
      if left >= 1
        h ^= (data[length & ~7] & 0xff)
        h *= m
        h &= LONG_MASK
      end

      h ^= h >> r
      h *= m
      h &= LONG_MASK
      h ^= h >> r

      h
    end
    private_class_method :hash64_str
  end
end
