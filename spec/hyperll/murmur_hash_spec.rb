require 'hyperll/murmur_hash'

module Hyperll
  describe MurmurHash do
    it 'hashes integers' do
      # java.lang.Integer.toHexString(Java::com::clearspring::analytics::hash::MurmurHash.hash(1))
      expect(MurmurHash.hash(1)).to eq("5b04c018".to_i(16))
      expect(MurmurHash.hash(2)).to eq("86e25492".to_i(16))
      expect(MurmurHash.hash(1000)).to eq("a373b8db".to_i(16))
      expect(MurmurHash.hash(5000)).to eq("5e1abaac".to_i(16))
      expect(MurmurHash.hash(18_000_000)).to eq("347b61c7".to_i(16))
    end

    it 'hashes integers larger than 32 bits' do
      expect(MurmurHash.hash(2 ** 33)).to eq("ab332279".to_i(16))
      expect(MurmurHash.hash((2 ** 36) - 1)).to eq("db264be3".to_i(16))
    end
  end
end
