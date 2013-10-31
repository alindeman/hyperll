require 'spec_helper'
require 'hyperll'

module Hyperll
  describe DeltaBytes do
    it 'uncompresses bytes' do
      expect(DeltaBytes.uncompress([2, -46, 5, -64, 4])).to eq([722, 1298])
    end

    it 'compresses bytes' do
      expect(DeltaBytes.compress([722, 1298])).to eq([2, 256 - 46, 5, 256 - 64, 4])
    end
  end
end
