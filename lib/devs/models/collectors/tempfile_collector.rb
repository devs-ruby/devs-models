require 'tempfile'

module DEVS
  module Models
    module Collectors
      class TempfileCollector < DEVS::AtomicModel
        def initialize
          super()
          @tempfile = Tempfile.new(self.name.to_s)
          DEVS::Hooks.subscribe(:post_simulation_hook, self, :close)
        end

        def external_transition(messages)
          messages.each do |message|
            value, port = *message
            unless value.nil?
              @tempfile.puts "#{port.name.to_s} #{self.time.to_s} #{value.to_s}"
            end
          end
        end

        def close
          @tempfile.close
          @tempfile.unlink
        end
      end
    end
  end
end
