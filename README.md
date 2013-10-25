# Hyperll [![Build Status](https://secure.travis-ci.org/alindeman/hyperll.png?branch=master)](http://travis-ci.org/alindeman/hyperll)

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

HyperLogLog can be serialized to a binary string. It is compatible with the
binary format from the Java [stream-lib](https://github.com/addthis/stream-lib)
library.

```ruby
hll = Hyperll::HyperLogLog.new(4)
hll.offer(1)
hll.offer(2)
hll.offer(3)
hll.serialize # => "\x00\x00\x00\x04\x00\x00\x00\f\x02\x00\x00\x00\x00\x00\x88\x00\x00\x00\x00\x00"

hll2 = Hyperll::HyperLogLog.unserialize("\x00\x00\x00\x04\x00\x00\x00\f\x02\x00\x00\x00\x00\x00\x88\x00\x00\x00\x00\x00")
hll2.cardinality # => 3
```
