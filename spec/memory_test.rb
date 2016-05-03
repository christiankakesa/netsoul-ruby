require 'objspace'
require 'memory_profiler'

require_relative '../lib/netsoul/client'

Netsoul::Client.new({}).connect

MemoryProfiler.report(trace: [Netsoul::Client]) do
  100.times do
    begin
      Netsoul::Client.new({}).connect
    rescue
    end
  end
end.pretty_print
