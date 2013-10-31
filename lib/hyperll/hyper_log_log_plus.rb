require_relative 'murmur_hash'

module Hyperll
  class HyperLogLogPlus
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

        ss_bytes = raw_sparse_set
        str << Varint.write_unsigned_var_int(ss_bytes.length).pack("C*")
        str << DeltaBytes.compress(ss_bytes).pack("C*")
      end

      str
    end
  end
end
