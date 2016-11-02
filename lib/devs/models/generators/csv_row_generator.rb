require 'csv'
module DEVS
  module Models
    module Generators
      # TODO attr_state
      class CSVRowGenerator < DEVS::AtomicModel

        attr_state :sigma, default: 0
        attr_state :input_file, :col_sep
        attr_state :step, default: 1

        output_port :row

        def initialize(name)
          super(name)
          DEVS::Hooks.subscribe(:before_simulation_hook, self)
        end

        def notify(hook)
          opts = @col_sep.nil? ? nil : { col_sep: @col_sep }
          File.open(input_file, 'r') do |file|
            @csv = CSV.parse(file.read, opts)
          end
          @csv.shift #headers
        end

        def internal_transition
          self.sigma = @last_row.nil? ? DEVS::INFINITY : @step
        end

        def output
          @last_row = @csv.shift
          unless @last_row.nil?
            @last_row.map! { |v| v.gsub(',', '.').to_f }
            post(@last_row, output_ports[:row])
          end
        end
      end
    end
  end
end
