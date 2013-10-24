# Hyperll

HyperLogLog implementation in pure Ruby

## Usage

HyperLogLog stores an estimation of the cardinality of a set. It can be merged
with other HyperLogLog instances.

```ruby
hll = Hyperll::HyperLogLog.new(10)
hll.offer(1)
hll.offer(2)
hll.offer(3)
hll.cardinality # => 3

hll2 = Hyperll::HyperLogLog.new(10)
hll2.offer(3)
hll2.offer(4)
hll2.offer(5)
hll.cardinality # => 3

merged = Hyperll::HyperLogLog.new(10)
merged.merge(hll, hll2)
merged.cardinality # => 5
```

### Serialization

TODO
