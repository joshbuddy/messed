require 'hpricot'

module Alloy
  module SMS
    module Aggregator
      module Celltrust
        class Serializer
          # Convert into an Alloy message format
          def self.deserialize_xml(xml)
            doc = Hpricot(xml)
            attributes = (doc/'/RecipientResponse')
            
            Message.new do |m|
              m.sender = attributes.at('originatoraddress').inner_text
              m.receiver = attributes.at('serveraddress').inner_text
              m.body = attributes.at('data').inner_text
              m.source = "Celltrust"
              # m['carrier'] = 
              yield m if block_given?
            end
          end
        end
      end
    end
  end
end