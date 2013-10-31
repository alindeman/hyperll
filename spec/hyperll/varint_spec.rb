require 'spec_helper'
require 'hyperll'

module Hyperll
  describe Varint do
    it 'reads unsigned variable length integers' do
      expect(Varint.read_unsigned_var_int([0x35])).to eq(0x35)
      expect(Varint.read_unsigned_var_int([0x81, 0x01])).to eq(0x81)
      expect(Varint.read_unsigned_var_int([0x81, 0x81, 0x01])).to eq(0x4081)
    end

    it 'writes unsigned variable length integers' do
      expect(Varint.write_unsigned_var_int(0x35)).to eq([0x35])
      expect(Varint.write_unsigned_var_int(0x81)).to eq([0x81, 0x01])
      expect(Varint.write_unsigned_var_int(0x4081)).to eq([0x81, 0x81, 0x01])
    end

    it 'treats negative integers as their twos complement unsigned representation' do
      expect(Varint.write_unsigned_var_int(-4)).to eq([252, 255, 255, 255, 15])
    end
  end
end
