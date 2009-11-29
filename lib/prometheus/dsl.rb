module Prometheus
  module DSL
    module Evaluator
      def evaluate(*args, &block)
        new(*args).tap {|e| e.instance_eval(&block) }
      end
    end

    def start_process(name, &block)
      @processes ||= []
      @processes << DSLProcess.evaluate(name, &block)
    end

    class DSLProcess
      extend Evaluator

      def running() Checks::Running end
      def memory_usage() Checks::MemoryUsage end

      def initialize(name)
        @name = name
        @checks = []
      end

      attr_accessor :checks

      def to_s
        @name
      end

      def check(type, options, &block)
        block ||= proc {}
        @checks << type.evaluate(self, options, &block)
      end
    end
  end
end