require 'nokogiri'

class Messed
  class Interface
    class Adapter
      class SMS
        class Celltrust < SMSHTTPReceiver
          
          def receive(request, message)
            message = self.class.deserialize_xml(params['xml'])
          end
          
          # Parse the Celltrust XML into a message
          def self.deserialize_xml(xml)
            doc = Nokogiri(xml)
            attributes = (doc/'/RecipientResponse')
            
            SMS::Message.new do |m|
              m.from = attributes.at('originatoraddress').inner_text
              m.to = attributes.at('serveraddress').inner_text
              m.body = attributes.at('data').inner_text
            end
          end
          
        end
      end
    end
  end
end