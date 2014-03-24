module DEVS
  module Models
    module Collectors
      class HashCollector < DEVS::AtomicModel
        def initialize
          super()
          @results = Hash.new { |hash, key| hash[key] = [] }
          @sigma = DEVS::INFINITY
        end

        external_transition do |messages|
          messages.each do |message|
            value, port = *message
            @results[port.name] << [@time, value] unless value.nil?
          end
        end

        time_advance { @sigma }
      end
    end
  end
end
