require 'json'
require 'base64'
require 'benchmark'
require 'hyperll'

encoded = JSON.load(File.read(File.join(File.dirname(__FILE__), 'fixtures', 'hlls.json')))

decoded = []
hlls = []
reencoded = []

Benchmark.bmbm do |x|
  x.report('decoding') do
    decoded = encoded.map { |s| Base64.decode64(s) }
  end

  x.report('deserializing') do
    hlls = decoded.map { |s| Hyperll::HyperLogLogPlus.unserialize(s) }
  end

  x.report('merging') do
    hll = Hyperll::HyperLogLogPlus.new(11, 25)
    hll.merge(*hlls)
  end

  x.report('encoding') do
    reencoded = hlls.map { |h| Base64.encode64(h.serialize) }
  end
end
