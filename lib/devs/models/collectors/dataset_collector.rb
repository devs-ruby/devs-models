module DEVS
  module Models
    module Collectors
      class DatasetCollector < DEVS::AtomicModel
        def initialize(opts={})
          super()
          @opts = {
            output: "#{self.name}_dataset"
            interleaved: true,
            column_spaces: 30
          }.merge(opts)

          if @opts[:interleaved]
            @file = File.new(@opts[:output], 'w+')
            @file.puts "# time - value"
          else
            @tempfiles = Hash.new do |hash, key|
              hash[key] = Tempfile.new("#{self.name}_#{key}")
            end
          end
        end

        def external_transition(messages)
          ports = input_ports.map(&:name)
          if @opts[:interleaved]
            hash = Hash.new { |hash, key| hash[key] = 'NaN' }
            messages.each do |message|
              payload, port = *message
              hash[port] = payload
            end
            spaces = @opts[:column_spaces]
            ports.each do |port|
              @file.printf("%-#{spaces}s %-#{spaces}s # %s\n", self.time, hash[port], port)
            end
          else
            messages.each do |message|
              payload, port = *message
              unless value.nil?
                spaces = @opts[:column_spaces]
                if payload.is_a?(Array)
                  strfmt = (["%-#{spaces}s"] * (payload.count + 1)).join(' ')
                  @tempfile[port.name].printf("#{strfmt}\n", self.time, *payload)
                else
                  @tempfile[port.name].printf("%-#{spaces}s %-#{spaces}s\n", self.time, payload)
                end
              end
            end
          end
        end

        def post_simulation_hook
          if @opts[:interleaved]
            @file.close
          else
            File.new(@opts[:output], 'w+') do |file|
              file.puts "# time - value"
              @tempfiles.each do |port, tempfile|
                file.puts "# #{port} data set"
                IO.copy_stream(tempfile, file)

                # insert an empty line to change dataset
                file.print("\n\n")

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
