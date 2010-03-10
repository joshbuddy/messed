require 'rack/request'
require 'rack/rewindable_input'

module Alloy
  module SMS
    module Aggregator
      module Clickatell
        class Middleware
          include Alloy::Middleware
          include Alloy::Middleware::Configurable

          def self.default_configuration
            {
              'gateway' => {
                'login' => '',
                'password' => '',
                'api_id' => ''
              }
            }
          end
          
          def initialize(app, configuration={})
            @app = app
            @configuration = self.class.default_configuration.merge(configuration)
          end

          def call(env)
            http_req = Rack::Request.new(env)
            env[Request::KEY] = Serializer.deserialize_xml(http_req.params['data']).params
            
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