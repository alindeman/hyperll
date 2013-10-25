require 'spec_helper'
require 'hyperll/murmur_hash'

module Hyperll
  describe MurmurHash do
    context '32-bit hashes' do
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

      it 'hashes strings' do
        # java.lang.Integer.toHexString(Java::com::clearspring::analytics::hash::MurmurHash.hash("abc123"))
        expect(MurmurHash.hash("abc123")).to eq("375301eb".to_i(16))
        expect(MurmurHash.hash("The quick brown fox jumped over the lazy dog")).to eq("fe639b68".to_i(16))
      end
    end

    context '64-bit hashes' do
      it 'hashes integers' do
        expect(MurmurHash.hash64(1)).to eq("a2784b1237e27ed3".to_i(16))
        expect(MurmurHash.hash64(2)).to eq("5a46c341a9e64ab8".to_i(16))
        expect(MurmurHash.hash64(1000)).to eq("83ce266f7c2adf23".to_i(16))
        expect(MurmurHash.hash64(5000)).to eq("249dffe7e2fc2217".to_i(16))
        expect(MurmurHash.hash64(18_000_000)).to eq("7ddf9ced923c3bea".to_i(16))
      end

      it 'hashes strings' do
        expect(MurmurHash.hash64("abc123")).to eq("cacf49d66f54b0c8".to_i(16))
        expect(MurmurHash.hash64("The quick brown fox jumped over the lazy dog")).to eq("64cbd20a182171be".to_i(16))
      end
    end
  end
end
