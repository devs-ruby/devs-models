module DEVS
  module Models
    module Collectors
      class IOLogger < DEVS::AtomicModel
        def initialize(io = STDOUT, from = nil)
          super()
          @io = io
          @from = from
          @sigma = DEVS::INFINITY
        end

        def external_transition(messages)
          messages.each do |message|
            value, port = *message
            unless value.nil?
              str = "#{value} on #{port.name} port at #{self.time}"
              str << " from #{@from}" if @from
              @io.puts str
            end
          end
        end

        def time_advance
          @sigma
        end
      end
    end
  end
end
