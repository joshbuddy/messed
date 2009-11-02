require 'twitter'

class Messed
  class Interface
    class Adapter
      class Twitter < Adapter

        def start(detach)
          raise "not implemented yet!"
        end
        
        def process_outgoing(message)
          httpauth = Twitter::HTTPAuth.new(interface.configuration['username'], interface.configuration['username'])
          client = Twitter::Base.new(httpauth)
          client.update(message.body)          
        end
        
      end
    end
  end
end