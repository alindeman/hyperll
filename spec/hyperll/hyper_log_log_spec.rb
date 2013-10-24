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

      estimate = hll.cardinality
      err = (estimate - size).abs / size.to_f
      expect(err).to be < 0.1
    end
  end
end
