require 'spec_helper'
require 'hyperll'

module Hyperll
  describe DeltaBytes do
    it 'uncompresses bytes' do
      expect(DeltaBytes.uncompress([-46, 5, -64, 4])).to eq([722, 1298])
      expect(DeltaBytes.uncompress([210, 5, 192, 4, 254, 67])).to eq([722, 1298, 10000])
    end

    it 'compresses bytes' do
      expect(DeltaBytes.compress([722, 1298])).to eq([256 - 46, 5, 256 - 64, 4])
      expect(DeltaBytes.compress([722, 1298, 10000])).to eq([210, 5, 192, 4, 254, 67])
    end
  end
end
