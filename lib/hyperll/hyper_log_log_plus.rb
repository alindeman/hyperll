require_relative 'murmur_hash'
require_relative 'delta_bytes'

module Hyperll
  class HyperLogLogPlus
    def self.unserialize(serialized)
      unpacked = serialized.unpack("C*")
      version = unpacked.shift(4) # integer, we don't currently use it

      p = Varint.read_unsigned_var_int(unpacked)
      sp = Varint.read_unsigned_var_int(unpacked)
      case format_type = Varint.read_unsigned_var_int(unpacked)
      when 0 # :normal
        size = Varint.read_unsigned_var_int(unpacked)
        rs_values = unpacked.pack("C*").unpack("N*")

        new(p, sp, rs_values).tap { |hllp|
          hllp.format = :normal
        }
      when 1 # :sparse
        sparse_set = DeltaBytes.uncompress(unpacked)
        new(p, sp, nil, sparse_set)
      else
        raise ArgumentError, "invalid format: #{format_type}"
      end
    end

    def serialize
      str = ""
      str << [-2].pack("N") # -VERSION
      str << Varint.write_unsigned_var_int(p).pack("C*")
      str << Varint.write_unsigned_var_int(sp).pack("C*")

      case format
      when :normal
        str << Varint.write_unsigned_var_int(0).pack("C*")

        rs_bytes = raw_register_set
        str << Varint.write_unsigned_var_int(rs_bytes.length * 4).pack("C*")
        str << rs_bytes.pack("N*")
      when :sparse
        str << Varint.write_unsigned_var_int(1).pack("C*")
        str << DeltaBytes.compress(raw_sparse_set).pack("C*")
      end

      str
    end
  end
end
