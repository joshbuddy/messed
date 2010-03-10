require 'builder'
require 'time'
require 'net/http'
require 'uri'

module Alloy
  module SMS
    module Aggregator
      module MBlox
        class Gateway
          include Aggregator
          END_POINT_URL = 'http://xml5.us.mblox.com:8180/send'

          attr_accessor :username, :password, :profile_id, :shortcode

          def initialize(opts={:gateway => {}})
            opts.symbolize_keys!
            
            @username = opts[:gateway][:username]
            @password = opts[:gateway][:password]
            @profile_id = opts[:gateway][:profile_id]
            @shortcode = opts[:gateway][:shortcode]
            
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
            xml_string = ''
            
            xml = Builder::XmlMarkup.new(:target => xml_string, :indent => 1)
            xml.instruct!
            xml.NotificationRequest(:Version => "3.5") { |nr|
              nr.NotificationHeader { |nh|
                nh.PartnerName(@username)
                nh.PartnerPassword(@password)
              }

              nr.NotificationList(:BatchID => "9999999") { |nl|
                nl.Notification(:SequenceNumber => "1", :MessageType => "SMS") { |n|
                  n.Message(message.body)
                  n.Profile(@profile_id)
                  n << "<SenderID Type=\"Shortcode\">#{@shortcode}</SenderID>" if !@shortcode.nil? and @shortcode != ""
                  # n.ExpireDate('11041812')  # Not used yet - optional for mblox
                  # n.Operator(carrier_id)
                  # n.Tariff('0')
                  n.Subscriber { |s|
                    s.SubscriberNumber(Alloy::SMS::PhoneNumber.canonicalize(message.receiver))
                  }
                  
                }
              }
            }

            res = Net::HTTP.post_form(URI.parse(END_POINT_URL),{
             'XMLDATA' => xml_string
            })
          end
        end
      end
    end
  end
end