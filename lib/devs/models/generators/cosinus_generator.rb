module DEVS
  module Models
    module Generators
      class CosinusGenerator < DEVS::AtomicModel
        def initialize(amplitude=1.0, frequency=50.0, phase=0.0, step=20, qss_order = 2)
          super()

          @qss_order = (1..3).include?(qss_order) ? qss_order : 2
          @amplitude = amplitude.to_f
          @frequency = frequency.to_f
          @phase = phase.to_f
          @step = step
          @pulsation = 2 * Math::PI * @frequency
          @sigma = 0
        end

        def internal_transition
          @sigma = 1.0 / @frequency / @step
        end

        def output
          value = case @qss_order
          when 1 then @amplitude * Math.cos(@pulsation * (self.time + @sigma) + @phase)
          when 2 then -@amplitude * @pulsation * Math.sin(@pulsation * (self.time + @sigma) + @phase)
          when 3 then -@amplitude * (@pulsation ** 2) * Math.cos(@pulsation * (self.time + @sigma) + @phase) / 2
          end

          output_ports.each { |port| post(value, port) }
        end

        def time_advance
          @sigma
        end
      end
    end
  end
end
