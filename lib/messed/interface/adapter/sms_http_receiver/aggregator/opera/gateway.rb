require 'builder'
require 'time'
require 'net/http'
require 'uri'

module Alloy
  module SMS
    module Aggregator
      module Opera
        class Gateway
          include Aggregator
          include Alloy::SMS::Carrier
          
          END_POINT_URL = 'http://http1.ireland.operatele.com:8080/PollEverywhere_Inc'

          attr_accessor :username, :password, :campaign_id

          def initialize(opts={})
            opts.symbolize_keys!
            
            @username = opts[:gateway][:username]
            @password = opts[:gateway][:password]
            @campaign_id = opts[:gateway][:campaign_id]
            @mapping_hash = eval(opts[:carrier_mapping][:mapping_hash])
            
            yield self if block_given?
          end

          # Sends a message and returns a false if something bad happens
          def send_message(message, carrier_id=nil)
            begin
              send_message!(message, carrier_id)
            rescue
              false
            end
          end

          # Posts a message to the mBlox servers to send
          # and outbound message
          def send_message!(message, carrier_id=nil)
            encoded_carrier_id = encode_carrier(carrier_id, @mapping_hash)
            res = Net::HTTP.post_form(URI.parse(END_POINT_URL),{
             'CampaignID'   => @campaign_id,
             'Username'     => @username,
             'Password'     => @password,
             'Channel'      => encoded_carrier_id,
             'MSISDN'       => message.receiver,
             'Content'      => message.body
            })
            res.body
          end
        end
      end
    end
  end
end