require 'thread'
require 'tempfile'

module DEVS
  module Models
    module Collectors
      class AsyncTempfileCollector < DEVS::AtomicModel
        attr_state :file_name

        def initialize(name)
          super(name)
          DEVS::Hooks.subscribe(:before_simulation_hook, self)
          DEVS::Hooks.subscribe(:after_simulation_hook, self)
        end

        def external_transition(messages)
          messages.each do |port, value|
            @queue << "#{port.name.to_s} #{self.time.to_s} #{value.to_s}"
          end
        end

        def notify(hook)
          case hook
          when :before_simulation_hook
            tempfile = Tempfile.new(@file_name || self.name.to_s)
            queue = Queue.new

            @consumer = Thread.new do
              loop do
                obj = @queue.pop
                break if obj == :terminate
                tempfile.puts(obj)
              end
            end

            @tempfile = tempfile
            @queue = queue
          when :after_simulation_hook
            @queue.puts(:terminate)
            @consumer.join
            @tempfile.close
            @tempfile.unlink
            @tempfile = nil
            @consumer = nil
          end
        end
      end
    end
  end
end
