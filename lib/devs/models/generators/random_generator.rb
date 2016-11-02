module DEVS
  module Models
    module Generators
      class RandomGenerator < DEVS::AtomicModel

        attr_state :min, default: 0
        attr_state :max, default: 10
        attr_state :min_step, :max_step, default: 1
        attr_state :sigma, default: 0
        attr_state(:random) { Random.new(Random.new_seed) }

        def internal_transition
          self.sigma = (@min_step + @random.rand * @max_step).round
        end

        def output
          messages_count = (1 + @random.rand * output_ports.count).round
          selected_ports = output_port_names.sample(messages_count)
          selected_ports.each { |port| post((@min + @random.rand * @max).round, port) }
        end
      end
    end
  end
end
