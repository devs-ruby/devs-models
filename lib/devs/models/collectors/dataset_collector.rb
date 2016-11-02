require 'tempfile'

module DEVS
  module Models
    module Collectors
      class DatasetCollector < DEVS::AtomicModel
        attr_state :output_file
        attr_state :interleaved, default: false
        attr_state :column_spaces, default: 30
        attr_state :ports_as_separate_datasets, default: true

        def initialize(name)
          super(name)
          DEVS::Hooks.subscribe(:before_simulation_hook, self)
          DEVS::Hooks.subscribe(:after_simulation_hook, self)
        end

        def output_file
          @output_file ||= "#{self.name}_dataset"
        end

        def notify(hook)
          case hook
          when :before_simulation_hook
            if @interleaved
              @file = File.new(self.output_file, 'w+')
              @file.puts "# time - value"
            else
              @tempfiles = Hash.new do |hash, key|
                hash[key] = Tempfile.new("#{self.name}_#{key}")
              end
            end
          when :after_simulation_hook
            if @interleaved
              @file.close
              @file = nil
            else
              File.open(self.output_file, 'w+') do |file|
                file.puts "# time - value"
                @tempfiles.each do |port, tempfile|
                  file.puts "# #{port} data set"
                  tempfile.rewind
                  IO.copy_stream(tempfile, file)
                  file.print @ports_as_separate_datasets ? "\n\n" : "\n"

                  # close tempfile
                  tempfile.close
                  tempfile.unlink
                end
                @tempfiles = nil
              end
            end
          end
        end

        def external_transition(messages)
          if @interleaved
            spaces = @column_spaces
            input_port_names.each do |port_name|
              @file.printf("%-#{spaces}s %-#{spaces}s # %s\n", self.time, messages[port_name] || 'NaN', port_name)
            end
          else
            messages.each do |port, payload|
              unless payload.nil?
                spaces = @column_spaces
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
      end
    end
  end
end
