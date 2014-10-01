require 'gnuplot'

module DEVS
  module Models
    module Collectors
      class PlotCollector < HashCollector
        def initialize(opts={})
          super()

          @opts = {
            terminal: 'postscript eps "Times-Roman" 12',
            output: 'plot.eps',
            style: 'data lines',
            title: self.name,
            ylabel: 'events',
            xlabel: 'time'
          }.merge(opts)

          DEVS::Hooks.subscribe(:post_simulation_hook, self, :plot)
        end

        def plot
          Gnuplot.open do |gp|
            Gnuplot::Plot.new(gp) do |plot|
              plot.terminal @opts[:terminal]
              plot.output @opts[:output]
              plot.style @opts[:style]
              plot.title  @opts[:title]
              plot.ylabel @opts[:ylabel]
              plot.xlabel @opts[:xlabel]

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
