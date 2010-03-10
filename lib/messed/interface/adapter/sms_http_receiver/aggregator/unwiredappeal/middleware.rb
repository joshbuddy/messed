require 'rack/request'
require 'rack/rewindable_input'

module Alloy
  module SMS
    module Aggregator
      module UnwiredAppeal
        class Middleware < Alloy::Middleware::HTTPGet
          def self.default_configuration
            {
              'gateway' => {
                'event_id' => '',
                'password' => ''
              },
              'url_params' => {
                'body' => 'body',
                'sender' => 'sender',
                'source' => 'source',
                'receiver' => 'receiver',
                'carrier' => 'carrier'
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
            #raise lookup_carrier_by_encoded_id(encode_carrier(decode_carrier(message['carrier'], CARRIER_MAPPING), CARRIER_MAPPING), CARRIER_MAPPING).inspect
            
            # At this point we should have an alloy message mapped out and stored in env.
            Thread.new @app, env, @configuration do |app, env, configuration|
              # Call app
              status, headers, body = app.call(env)
              # Send response back to gateway
              if status == 200 and not body.blank?
                Gateway.new(configuration).send_message!(Alloy::Middleware::Response.new(env), message['decoded_carrier'])
              end
            end
            
            Alloy::Middleware.blank_http_response
          end
          
          def gateway
            Gateway.new(configuration)
          end
        end
      end
    end
  end
end