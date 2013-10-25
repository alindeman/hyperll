require 'spec_helper'
require 'hyperll/varint'

module Hyperll
  describe Varint do
    it 'reads unsigned variable length integers' do
      expect(Varint.read_unsigned_var_int([0x35])).to eq(0x35)
      expect(Varint.read_unsigned_var_int([0x81, 0x01])).to eq(0x81)
      expect(Varint.read_unsigned_var_int([0x81, 0x81, 0x01])).to eq(0x4081)
    end
  end
end
