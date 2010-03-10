require 'nokogiri'

class Messed
  class Interface
    class Adapter
      class SMS
        class Clickatell < SMSHTTPReceiver
          
          def receive(request, message)
            message = self.class.deserialize_xml(params['data'])
          end
          
          def self.deserialize_xml(xml, &block)
            doc = Nokogiri(xml)
            attributes = (doc/'/clickmo')
            
            SMS::Message.new do |m|
              m.from  = attributes.at('from').inner_text
              m.to    = attributes.at('to').inner_text
              m.body  = attributes.at('text').inner_text
            end
          end
          
        end
      end
    end
  end
end