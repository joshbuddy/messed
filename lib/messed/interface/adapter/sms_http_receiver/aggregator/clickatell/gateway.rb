require 'hpricot'
require 'time'
require 'net/http'
require 'uri'

module Alloy
  module SMS
    module Aggregator
      module Clickatell
        class Gateway
          include Aggregator
          END_POINT_URL = 'http://api.clickatell.com/http/sendmsg'

          attr_accessor :login, :password, :api_id

          def initialize(opts={:gateway => {}})
            opts.symbolize_keys!
            
            if opts.include?(:gateway) # TODO Shitty hack. Replace with nested attributes...
              @login = opts[:gateway][:login]
              @password = opts[:gateway][:password]
              @api_id = opts[:gateway][:api_id]
            end
            
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

          # Posts a message to the Clickatell servers to send
          # and outbound message
          def send_message!(message, carrier_id=nil)
            res = Net::HTTP.post_form(URI.parse(END_POINT_URL),{
             'api_id'   => @api_id,
             'user'     => @login,
             'password' => @password,
             'to'       => message.receiver,
             'text'     => message.body
            })
            res.body
          end
        end
      end
    end
  end
end