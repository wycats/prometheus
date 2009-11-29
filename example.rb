$:.push "lib"
require "prometheus"

r = Prometheus::Reactor.new do
  start_process "vm_stat 1" do
    check running, :every => 1

    check memory_usage, :below => 150.mb, :every => 5 do
      must_pass 3, :of => 5
    end
  end
end

r.start