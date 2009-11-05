require 'twitter'
require 'jack'

class Messed
  class Interface
    class Adapter
      class TwitterSender < Adapter
        
        def start(detach)
          logger.info "Starting #{interface.name.to_s}"
          
          interface.application.outgoing.take do |message|
            process_outgoing(message)
          end
        end
        
        def process_outgoing(message)
          httpauth = Twitter::HTTPAuth.new(interface.configuration['username'], interface.configuration['username'])
          client = Twitter::Base.new(httpauth)
          if message.in_reply_to
            client.update(message.body, :in_reply_to_status_id => message.in_reply_to.id)
          else
            client.update(message.body)
          end
        end
        
      end
    end
  end
end