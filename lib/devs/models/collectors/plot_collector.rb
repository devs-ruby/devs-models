begin
  require 'gnuplot'
rescue LoadError
  DEVS.logger.warn "Unable to generate a plot using Gnuplot"\
                   ". Please 'gem install gnuplot'." if DEVS.logger
end

module DEVS
  module Models
    module Collectors
      class PlotCollector < HashCollector
        attr_state :terminal, default: 'postscript eps "Times-Roman" 12'
        attr_state :output, default: 'plot.eps'
        attr_state :style, default: 'data lines'
        attr_state :ylabel, default: 'events'
        attr_state :xlabel, default: 'time'

        def title
          @title ||= self.name.to_s
        end

        def initialize(name, opts={})
          super(name)
          DEVS::Hooks.subscribe(:after_simulation_hook, self)
        end

        def notify(hook)
          if defined? Gnuplot
            Gnuplot.open do |gp|
              Gnuplot::Plot.new(gp) do |plot|
                plot.terminal @terminal
                plot.output @output
                plot.style @style
                plot.title  @title
                plot.ylabel @ylabel
                plot.xlabel @xlabel

                @results.each { |key, value|
                  x = []
                  y = []
                  @results[key].each { |a| x << a.first; y << a.last }
                  plot.data << Gnuplot::DataSet.new([x, y]) do |ds|
                    ds.title = key
                  end
                }
              end
            end
          end
        end
      end
    end
  end
end
