require_relative 'varint'

module Hyperll
  class DeltaBytes
    def self.compress(bytes)
    end

    def self.uncompress(bytes)
      uncompressed = []
      previous_value = 0

      length = Varint.read_unsigned_var_int(bytes)
      length.times do
        next_value = Varint.read_unsigned_var_int(bytes)

        uncompressed << next_value + previous_value
        previous_value = uncompressed.last
      end

      uncompressed
    end
  end
end
