require 'hyperll/register_set'

module Hyperll
  describe RegisterSet do
    it "retrieves previously set values" do
      rs = RegisterSet.new(2 ** 4)

      rs[0] = 11
      expect(rs[0]).to eq(11)
    end

    it "retrieves previously set values for small bits" do
      rs = RegisterSet.new(6)

      rs[0] = 11
      expect(rs[0]).to eq(11)
    end
  end
end
