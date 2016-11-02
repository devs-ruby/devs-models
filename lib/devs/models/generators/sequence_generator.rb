module DEVS
  module Models
    module Generators
      class SequenceGenerator < DEVS::AtomicModel
        attr_state :min, :step, default: 1
        attr_state :max, default: 10
        attr_state :sigma, default: 0

        output_port :value

        def output
          post @min, :value
        end

        def internal_transition
          @min += @step
          @sigma = if @min > @max
            DEVS::INFINITY
          else
            @step
          end
        end
      end
    end
  end
end
