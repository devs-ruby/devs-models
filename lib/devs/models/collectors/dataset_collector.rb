require 'tempfile'

module DEVS
  module Models
    module Collectors
      class DatasetCollector < DEVS::AtomicModel
        def initialize(opts={})
          super()
          @opts = {
            output: "#{self.name}_dataset",
            interleaved: false,
            column_spaces: 30,
            ports_as_separate_datasets: true
          }.merge(opts)

          if @opts[:interleaved]
            @file = File.new(@opts[:output], 'w+')
            @file.puts "# time - value"
          else
            @tempfiles = Hash.new do |hash, key|
              hash[key] = Tempfile.new("#{self.name}_#{key}")
            end
          end

          DEVS::Hooks.subscribe(:post_simulation_hook, self, :close)
        end

        def external_transition(messages)
          ports = input_ports.map(&:name)
          if @opts[:interleaved]
            spaces = @opts[:column_spaces]
            hash = {}
            messages.each do |message|
              payload, port = *message
              hash[port.name] = payload
            end
            ports.each do |port|
              @file.printf("%-#{spaces}s %-#{spaces}s # %s\n", self.time, hash[port] || 'NaN', port)
            end
          else
            messages.each do |message|
              payload, port = *message
              unless payload.nil?
                spaces = @opts[:column_spaces]
                if payload.is_a?(Array)
                  strfmt = (["%-#{spaces}s"] * (payload.count + 1)).join(' ')
                  @tempfiles[port.name].printf("#{strfmt}\n", self.time, *payload)
                else
                  @tempfiles[port.name].printf("%-#{spaces}s %-#{spaces}s\n", self.time, payload)
                end
              end
            end
          end
        end

        def close
          if @opts[:interleaved]
            @file.close
          else
            File.open(@opts[:output], 'w+') do |file|
              file.puts "# time - value"
              @tempfiles.each do |port, tempfile|
                file.puts "# #{port} data set"
                tempfile.rewind
                IO.copy_stream(tempfile, file)
                file.print @opts[:ports_as_separate_datasets] ? "\n\n" : "\n"

                # close tempfile
                tempfile.close
                tempfile.unlink
              end
              @tempfiles = nil
            end
          end
        end
      end
    end
  end
end
