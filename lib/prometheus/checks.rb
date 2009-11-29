module Prometheus
  class Check
    def initialize(process, options)
      @process, @options = process, options
    end

    def tick
      @next_tick = (Time.now.to_i - $start) + options[:every]
      self
    end

    attr_reader :pass, :total, :options, :next_tick
    def must_pass(number, hash)
      @pass, @total = number, hash[:of]
    end

    def run
    end
  end
end

require "prometheus/checks/running"
require "prometheus/checks/memory_usage"