require 'rack/request'
require 'rack/rewindable_input'

module Alloy
  module SMS
    module Aggregator
      module MBlox
        class Middleware < Alloy::Middleware::HTTPGet
          def self.default_configuration
            {
              'gateway' => {
                'username' => '',
                'password' => '',
                'profile_id' => '',
                'shortcode' => ''
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
            http_req, message = Rack::Request.new(env), Alloy::Middleware::Request.new(env)
            deserialized_message, carrier_id = Serializer.deserialize_xml(http_req.params['xmldata'] || http_req.params['XMLDATA'])
            env[Request::KEY] = deserialized_message.params
            
            # Decode the carrier against our master list
            mapping_hash = eval(@configuration['carrier_mapping']['mapping_hash'])          
            message['decoded_carrier'] = decode_carrier(carrier_id, mapping_hash)

            # At this point we should have an alloy message mapped out and stored in env.
            Thread.new @app, env, @configuration do |app, env, configuration|
              # Call app
              status, headers, body = app.call(env)
              # Send response back to gateway
              if status == 200 and not body.blank?
                Gateway.new(configuration).send_message! Alloy::Middleware::Response.new(env)
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