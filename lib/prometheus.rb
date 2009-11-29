require "prometheus/dsl"
require "prometheus/checks"
require "prometheus/core_ext"

module Prometheus
  class CheckList < Array
    def sort_by_next_tick
      sort! {|a,b| a.next_tick <=> b.next_tick }
    end

    def insert(check)
      self << check.tick
      sort_by_next_tick
    end
  end

  class Reactor
    include Prometheus::DSL

    attr_reader :processes

    def initialize(&block)
      $start = Time.now.to_i
      @checks = CheckList.new
      instance_eval(&block)
    end

    def start
      @processes.each do |process|
        process.checks.each {|c| @checks.insert(c) }
      end

      checks, start = @checks, $start

      loop do
        GC.start

        check = checks.shift
        check.run
        checks.insert(check)
        sleep_time = checks.first.next_tick - (Time.now.to_i - start)

        sleep sleep_time if sleep_time > 0
      end
    end
  end
end
