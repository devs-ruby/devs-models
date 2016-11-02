require 'tempfile'

module DEVS
  module Models
    module Collectors
      class TempfileCollector < DEVS::AtomicModel
        attr_state :file_name

        def initialize(name)
          super(name)
          DEVS::Hooks.subscribe(:before_simulation_hook, self)
          DEVS::Hooks.subscribe(:after_simulation_hook, self)
        end

        def external_transition(messages)
          messages.each do |port, value|
            @tempfile.puts "#{port.name.to_s} #{self.time.to_s} #{value.to_s}"
          end
        end

        def notify(hook)
          case hook
          when :before_simulation_hook
            @tempfile = Tempfile.new(@file_name || self.name.to_s)
          when :after_simulation_hook
            @tempfile.close
            @tempfile.unlink
            @tempfile = nil
          end
        end
      end
    end
  end
end
