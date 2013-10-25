require 'hyperll/delta_bytes'

module Hyperll
  describe DeltaBytes do
    it 'uncompressed bytes' do
      expect(DeltaBytes.uncompress([2, -46, 5, -64, 4])).to eq([722, 1298])
    end
  end
end
