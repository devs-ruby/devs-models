module DEVS
  module Models
    module Generators
      class CosinusGenerator < DEVS::AtomicModel

        attr_state :qss_order, default: 2.0
        attr_state :amplitude, default: 1.0
        attr_state :frequency, default: 50.0
        attr_state :step, default: 20.0
        attr_state :sigma, :phase, default: 0.0

        def pulsation
          @pulsation ||= 2 * Math::PI * @frequency
        end

        def internal_transition
          @sigma = 1.0 / @frequency / @step
        end

        def output
          value = case @qss_order
          when 1 then @amplitude * Math.cos(self.pulsation * (self.time + @sigma) + @phase)
          when 2 then -@amplitude * self.pulsation * Math.sin(self.pulsation * (self.time + @sigma) + @phase)
          when 3 then -@amplitude * (self.pulsation ** 2) * Math.cos(self.pulsation * (self.time + @sigma) + @phase) / 2
          end

          output_ports.each_key { |port| post(value, port) }
        end
      end
    end
  end
end
