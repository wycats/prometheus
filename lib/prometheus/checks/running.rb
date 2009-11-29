module Prometheus
  module Checks
    class Running < Check
      extend DSL::Evaluator

      def run
        if @started && check_pid
          puts "#{@process} is alive"
        else
          puts "#{@process} is dead; starting it"
          start
        end
      end

      def start
        read, write = IO.pipe

        pid = fork do
          read.close
          Process.setsid
          exit if fork
          write.puts Process.pid.to_s
          Dir.chdir "/"
          ::File.umask 0000
          STDIN.reopen "/dev/null"
          STDOUT.reopen "/dev/null", "a"
          STDERR.reopen "/dev/null", "a"
          exec @process.to_s
        end

        @pid = read.readline.to_i
        @started = true
      end

      def check_pid
        @pid && Process.kill(0, @pid)
      rescue Errno::ESRCH
        false
      end
    end
  end
end