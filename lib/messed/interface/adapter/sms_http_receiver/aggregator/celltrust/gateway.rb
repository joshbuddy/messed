require 'hpricot'
require 'time'
require 'net/https'
require 'uri'

module Alloy
  module SMS
    module Aggregator
      module Celltrust
        # Send outbound messags to Celltrust
        class Gateway
          include Aggregator
          attr_accessor :login, :password, :customer_nickname

          END_POINT_URL = 'https://www.primemessage.net/TxTNotify/TxTNotify'

          def initialize(opts={:gateway=>{}},&block)
            opts.symbolize_keys!
            
            if opts.include?(:gateway) # Shitty hack
              @login = opts[:gateway][:login]
              @password = opts[:gateway][:password]
              @customer_nickname = opts[:gateway][:customer_nickname]
            end
            
            yield self if block_given?
          end

          # Sends the message and raises a false if something gets messed up
          def send_message(message, carrier_id=nil)
            begin
              send_message!(message, carrier_id)
            rescue
              false
            end
          end

          # Sends the messages and bubbles up exceptions to the server
          def send_message!(message, carrier_id=nil)
            http = Net::HTTP.new(URI.parse(END_POINT_URL).host, Net::HTTP.https_default_port)
            http.use_ssl = true
            res = http.get(URI.parse(END_POINT_URL).path + "?PhoneDestination=#{URI.escape(message.receiver)}&Message=#{URI.escape(message.body)}&CustomerNickname=#{@customer_nickname}&Username=#{@login}&Password=#{@password}", nil)
            res.body
          end
        end
      end
    end
  end
end