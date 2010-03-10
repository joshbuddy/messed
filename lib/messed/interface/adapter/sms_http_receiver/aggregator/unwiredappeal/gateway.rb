require 'builder'
require 'time'
require 'net/http'
require 'uri'

module Alloy
  module SMS
    module Aggregator
      module UnwiredAppeal
        class Gateway
          include Aggregator
          include Alloy::SMS::Carrier
          
          END_POINT_URL = 'http://appsrv.unwiredappeal.com/uwa_umap/eventhandler.srv'

          attr_accessor :event_id, :password, :mapping_hash

          def initialize(opts={})
            opts.symbolize_keys!
            
            @event_id = opts[:gateway][:event_id]
            @password = opts[:gateway][:password]
            @mapping_hash = eval(opts[:carrier_mapping][:mapping_hash])
            
            yield self if block_given?
          end

          # Sends a message and returns a false if something bad happens
          def send_message(message, carrier_id)
            begin
              send_message!(message, carrier_id)
            rescue
              false
            end
          end

          # Posts a message to the mBlox servers to send
          # and outbound message
          def send_message!(message, carrier_id)
            encoded_carrier_id = encode_carrier(carrier_id, @mapping_hash)
            res = Net::HTTP.get_response(URI.parse("#{END_POINT_URL}?evid=#{@event_id}&pw=#{@password}&carrier=#{encoded_carrier_id}&number=#{Alloy::SMS::PhoneNumber.canonicalize(message.receiver)}&msg=#{URI.encode(message.body)}"))
          end
        end
      end
    end
  end
end