module Prometheus
  module Checks
    class MemoryUsage < Check
      extend DSL::Evaluator

      def run
        puts "Checking if memory usage for #{@process} is bigger than #{@options[:below]}"
      end
    end
  end
end