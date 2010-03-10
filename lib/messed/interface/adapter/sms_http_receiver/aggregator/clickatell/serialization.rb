module Alloy
  module SMS
    module Aggregator
      module Clickatell
        class Serializer
          # Convert into an Alloy message format
          def self.deserialize_xml(xml, &block)
            doc = Hpricot(xml)
            attributes = (doc/'/clickmo')
            
            Message.new do |m|
              m.sender = attributes.at('from').inner_text
              m.receiver = attributes.at('to').inner_text
              m.body = attributes.at('text').inner_text
              yield m if block_given?
            end
          end
        end
      end
    end
  end
end