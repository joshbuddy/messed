require 'rack/request'
require 'rack/rewindable_input'

module Alloy
  module SMS
    module Aggregator
      module Celltrust
        class Middleware
          include Alloy::Middleware
          include Alloy::Middleware::Configurable
          
          def self.default_configuration
            {
              'gateway' => {
                'login' => '',
                'password' => '',
                'customer_nickname' => ''
              }
            }
          end
          
          def initialize(app, configuration={})
            @app = app
            @configuration = self.class.default_configuration.merge(configuration)
          end

          # Derializes a Celltrust XML message into an Alloy::Message,
          # which is passed along with the request
          def call(env)
            http_req = Rack::Request.new(env)
            env[Request::KEY] = Serializer.deserialize_xml(http_req.params['xml']).params

            Thread.new @app, env, @configuration do |app, env, configuration|
              status, headers, body = app.call(env)
              # # Figure out how to introduce a message queue in here, but make it pluggable
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