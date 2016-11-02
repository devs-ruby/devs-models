module DEVS
  module Models
    module Collectors
      class HashCollector < DEVS::AtomicModel
        attr_state(:results) { Hash.new { |hash, key| hash[key] = [] }}

        def external_transition(messages)
          messages.each do |port,value|
            @results[port.name] << [@time, value] unless value.nil?
          end
        end
      end
    end
  end
end
