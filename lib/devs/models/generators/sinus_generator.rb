module DEVS
  module Models
    module Generators
      class SinusGenerator < DEVS::AtomicModel
        def initialize(amplitude=1.0, frequency=50.0, phase=0.0, step=20)
          super()

          @amplitude = amplitude.to_f
          @frequency = frequency.to_f
          @phase = phase.to_f
          @step = step
          @pulsation = 2 * Math::PI * @frequency
          @dt = 1 / @frequency / step.to_f
          @sigma = 0
        end

        def internal_transition
          @sigma = @dt
        end

        def output
          value = @amplitude * @pulsation * Math.cos(@pulsation * (self.time + @sigma) * @phase)
          output_ports.each { |port| post(value, port) }
        end

        def time_advance
          @sigma
        end
      end
    end
  end
end
