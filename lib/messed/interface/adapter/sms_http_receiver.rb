require 'thin'

class Messed
  class Interface
    class Adapter
      class SMSHTTPReceiver < Adapter
        include Logger::LoggingModule
        
        attr_accessor :port, :host, :configuration
        
        # This lets us make our aggregator classes incredibly simple so they don't have
        # to concern themselves with middleware. See the subclasses for an example
        class Middleware
          def initialize(app, sms_http_receiver)
            @app, @sms_http_receiver = app, aggregator
          end
          
          def call(env)
            env, message = Rack::Request.new(env), SMS::Message.new
            @sms_http_receiver.receive env, message
            env[self.class.rack_key] = message
            @app.call env
          end
          
          # This is the param that parsed messages get stored in the rack context
          def self.rack_key
            'messed.message'
          end
        end
        
        def type
          :sms
        end
        
        def init
          @port = 9000
          @host = '0.0.0.0'
        end
        
        # Generally you'll want to return a blank response, but this may need to be
        # changed depending on the aggregator.
        def response
          [204, {}, []]
        end
        
        # Parse out the incoming message in the middleware and drop it on this queue
        def start
          thin.start do
            use Middleware, self
            run Proc.new do |env|
              interface.application.incoming << env[Middleware.rack_key]
              response
            end
          end
        end
        
      private
        def thin
          @thin ||= Thin.new host, port
        end
      end
    end
  end
end