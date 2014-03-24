require 'thread'

module DEVS
  module Models
    module Collectors
      class AsyncTempfileCollector < DEVS::AtomicModel
        def initialize
          super()
          tempfile = Tempfile.new(self.name.to_s)
          queue = Queue.new
          @run = true

          @consumer = Thread.new do
            tempfile.puts(queue.pop) while @run
          end
          @tempfile = tempfile
          @queue = queue
        end

        def external_transition(messages)
          messages.each do |message|
            value, port = *message
            unless value.nil?
              @queue << "#{port.name.to_s} #{self.time.to_s} #{value.to_s}"
            end
          end
        end

        def post_simulation_hook
          @run = false
          @consumer.join
          @tempfile.close
          @tempfile.unlink
        end
      end
    end
  end
end
