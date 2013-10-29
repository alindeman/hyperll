require 'base64'
require 'hyperll'
require 'rblineprof'

fixtures = File.readlines(File.join(File.dirname(__FILE__), 'fixtures', '10000.txt'))
hllps = fixtures.map { |line|
  Hyperll::HyperLogLogPlus.unserialize(Base64.decode64(line))
}

hllp = Hyperll::HyperLogLogPlus.new(11, 16)
profile = lineprof(/hyper_log_log_plus\.rb/) do
  hllps.each do |h|
    hllp.merge(h)
  end
end

puts "Total cardinality: #{hllp.cardinality}"

profile.each do |file, lines|
  File.readlines(file).each_with_index do |line, num|
    wall, cpu, calls, allocations, *rest = lines[num+1]

    if calls && calls > 0
      printf "% 8.1fms + % 8.1fms (% 8d) | %s", cpu/1000.0, (wall-cpu)/1000.0, calls, line
      # printf "% 8.1fms (% 5d) | %s", wall/1000.0, calls, line
    else
      printf "                                   | %s", line
      # printf " | %s", line
    end
  end
end
