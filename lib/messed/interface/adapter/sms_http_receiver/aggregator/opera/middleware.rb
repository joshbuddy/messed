require 'rack/request'
require 'rack/rewindable_input'

module Alloy
  module SMS
    module Aggregator
      module Opera
        class Middleware < Alloy::Middleware::HTTPGet
          def self.default_configuration
            {
              'gateway' => {
                'username' => '',
                'password' => '',
                'campaign_id' => ''
              },
              'url_params' => {
                'body' => 'content',
                'sender' => 'msisdn',
                'source' => 'Opera',
                'receiver' => 'shortcode',
                'carrier' => 'channel'
              },
              'carrier_mapping' => {
                'mapping_hash' => ''
              }
            }
          end
          
          def call(env)
            # This is a double assignment that decorates env with Rack::Request
            # and Message.rack. Both of these maintain references to various pieces
            # of env but just make it easier to manipulate.
            req, message = Rack::Request.new(env), Alloy::Middleware::Request.new(env)
            @configuration['url_params'].each do |canonical, source|
              message[canonical] = req.params[source]
              # This is an example of a mapping on the specific key called 'sender'.
              # These mappings are defined above in default_configuration['url_params']
              # env['alloy.request']['sender'] = req.params['sender']
            end

            # Decode the carrier against our master list
            mapping_hash = eval(@configuration['carrier_mapping']['mapping_hash'])          
            message['decoded_carrier'] = decode_carrier(message['carrier'], mapping_hash)
            
            # At this point we should have an alloy message mapped out and stored in env.
            Thread.new @app, env, @configuration do |app, env, configuration|
              # Call app
              status, headers, body = app.call(env)
              # Send response back to gateway
              if status == 200 and not body.blank?
                Gateway.new(configuration).send_message!(Alloy::Middleware::Response.new(env), message['decoded_carrier'])
              end
            end
            
            opera_success_http_response
          end
          
          def gateway
            Gateway.new(configuration)
          end
          
          private
          
          # Yep, their API spec expects an HTTP 200 OK with body text 'Fail' to represent a failure.
          # Meanwhile, it expects an HTTP 200 OK with body text 'Success' to represent
          # success. Isn't that what a 200 OK is supposed to mean? DUMB.
          def opera_success_http_response
            [ 200, {'Content-Type' => 'text/html'}, 'Success' ]
          end
          
          def opera_fail_http_response
            [ 200, {'Content-Type' => 'text/html'}, 'Fail' ]
          end
        end
      end
    end
  end
end