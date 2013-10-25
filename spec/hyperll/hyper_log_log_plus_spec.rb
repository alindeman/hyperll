require 'base64'
require 'hyperll/hyper_log_log_plus'

module Hyperll
  describe HyperLogLogPlus do
    describe 'validations' do
      specify 'p must be greater than or equal to 4' do
        expect { HyperLogLogPlus.new(1) }.to raise_error(ArgumentError)
      end

      specify 'sp must be less than 32' do
        expect { HyperLogLogPlus.new(11, 32) }.to raise_error(ArgumentError)
      end

      specify 'p must be less than or equal to sp' do
        expect { HyperLogLogPlus.new(16, 11) }.to raise_error(ArgumentError)
      end
    end

    describe 'format' do
      it 'defaults to normal (non-sparse) format' do
        hllp = HyperLogLogPlus.new(11)
        expect(hllp.format).to eq(:normal)
      end

      it 'defaults to sparse format if sp is specified' do
        hllp = HyperLogLogPlus.new(11, 16)
        expect(hllp.format).to eq(:sparse)
      end
    end

    describe 'serialization' do
      it 'unserializes a normal format instance from a string' do
        # hllp = Java::com::clearspring::analytics::stream::cardinality::HyperLogLogPlus.new(4)
        # hllp.offer(1)
        # hllp.offer(2)
        # h.getBytes()
        serialized = [-1, -1, -1, -2, 4, 0, 0, 12, 2, 0, 0, 0, 0, 48, 0, 0, 0, 0, 0, 0].pack("C*")
        hllp = HyperLogLogPlus.unserialize(serialized)

        expect(hllp.format).to eq(:normal)
        expect(hllp.p).to eq(4)
        expect(hllp.sp).to eq(0)
        expect(hllp.cardinality).to eq(2)
      end

      it 'unserializes a sparse format instance from a string'
    end
  end
end
