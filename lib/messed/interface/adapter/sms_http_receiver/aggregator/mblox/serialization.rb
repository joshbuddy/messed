module Alloy
  module SMS
    module Aggregator
      module MBlox
        class Serializer
          # Convert into an Alloy message format
          def self.deserialize_xml(xml, &block)
            doc = Hpricot(xml)
            attributes = (doc/'/ResponseService/ResponseList/Response')
            carrier_id = nil
            
            #raise "Hell"
            #raise attributes.at('originatingnumber').inner_text.inspect
            m = Message.new do |m|
              m.sender = attributes.at('originatingnumber').inner_text
              m.receiver = attributes.at('destination').inner_text
              m.body = attributes.at('data').inner_text
              carrier_id = attributes.at('deliverer').inner_text
              yield m if block_given?
            end
            
            return m, carrier_id
          end
        end
      end
    end
  end
end