require 'twitter'

class Messed
  class Base
    class Adapter
      class Twitter < Adapter

        def start(detach)
          raise "not implemented yet!"
        end
        
        def process_outgoing(message)
          httpauth = Twitter::HTTPAuth.new(base.configuration['username'], base.configuration['username'])
          client = Twitter::Base.new(httpauth)
          client.update(message.body)          
        end
        
      end
    end
  end
end