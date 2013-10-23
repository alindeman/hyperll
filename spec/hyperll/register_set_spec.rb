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

    it "merges with other register sets" do
      rand = Random.new(2)
      count = 32
      rs = RegisterSet.new(count)

      rss = []
      5.times do |i|
        rss[i] = RegisterSet.new(count)
        count.times do |pos|
          val = rand.rand(10)
          rs.update_if_greater(pos, val)
          rss[i][pos] = val
        end
      end

      merged = RegisterSet.new(count)
      rss.each do |set|
        merged.merge(set)
      end

      rs.each_with_index do |value, index|
        expect(value).to eq(merged[index])
      end
    end

    it "merges with other register sets using update_if_greater" do
      rand = Random.new(2)
      count = 32
      rs = RegisterSet.new(count)

      rss = []
      5.times do |i|
        rss[i] = RegisterSet.new(count)
        count.times do |pos|
          val = rand.rand(10)
          rs.update_if_greater(pos, val)
          rss[i][pos] = val
        end
      end

      merged = RegisterSet.new(count)
      rss.each do |set|
        set.each_with_index do |value, index|
          merged.update_if_greater(index, value)
        end
      end

      rs.each_with_index do |value, index|
        expect(value).to eq(merged[index])
      end
    end
  end
end
