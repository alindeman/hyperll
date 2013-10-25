module Hyperll
  class Varint
    def self.read_unsigned_var_int(bytes)
      value, i, b = 0, 0, 0
      while (b = bytes.shift) & 0x80 != 0
        value |= (b & 0x7F) << i

        i += 7
        raise "Variable length quantity is too long" if i > 35
      end

      value | (b << i)
    end
  end
end
