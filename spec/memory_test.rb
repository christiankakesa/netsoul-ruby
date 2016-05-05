exit 0 unless RUBY_VERSION >= '2.1.0'

require 'memory_profiler'

require_relative '../lib/netsoul/client'

Netsoul::Client.new({}).connect

MemoryProfiler.report(trace: [Netsoul::Client]) do
  100.times do
    # rubocop:disable all
    begin
      Netsoul::Client.new({}).connect
    rescue
    end
    # rubocop:enable all
  end
end.pretty_print
