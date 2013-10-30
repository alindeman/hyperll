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

    def self.write_unsigned_var_int(value)
      bytes = []

      value = [value].pack("N").unpack("N").first
      while (value & 0xFFFFFF80) != 0
        bytes << ((value & 0x7F) | 0x80)
        value >>= 7
      end

      bytes << (value & 0x7F)
      bytes
    end
  end
end
