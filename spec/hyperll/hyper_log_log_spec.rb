require 'hyperll/hyper_log_log'

module Hyperll
  describe HyperLogLog do
    it 'computes cardinality' do
      hll = HyperLogLog.new(16)
      hll.offer(0)
      hll.offer(1)
      hll.offer(2)
      hll.offer(3)
      hll.offer(16)
      hll.offer(17)
      hll.offer(18)
      hll.offer(19)
      hll.offer(19)

      expect(hll.cardinality).to eq(8)
    end

    it 'is accurate within an expected amount for high cardinalities' do
      hll = HyperLogLog.new(10)

      size = 1_000_000
      size.times do
        hll.offer(rand(2**63))
      end

      expect(hll.cardinality).to be_within(10).percent_of(size)
    end

    it 'merges with other hyperloglog instances' do
      size = 100_000
      hlls = Array.new(5) do
        HyperLogLog.new(16).tap { |hll|
          size.times { hll.offer(rand(2**63)) }
        }
      end

      merged = HyperLogLog.new(16)
      merged.merge(*hlls)

      expect(merged.cardinality).to be_within(10).percent_of(size * hlls.length)
    end
  end
end
