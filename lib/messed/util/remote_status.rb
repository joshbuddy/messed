class Messed
  module Util
    class RemoteStatus
      
      attr_reader :status
      
      class StatusHandler < EM::Connection

        attr_accessor :status
        
        def post_init
          puts "post..."
          send_data "status\r\n"
        end

        def receive_data(data)
          JSON.parse(data).each do |key, value|
            self.status[key] = status
          end
          EM.stop_event_loop
        end
      end
      
      def initialize(host, port)
        host ||= '127.0.0.1'
        @status = {}
        EM.run do
          EM.add_timer(5) {
            @status['error'] = "timeout on connect"
            EM.stop_event_loop
          }
          begin
            EM.connect(host, port, StatusHandler) do |handler|
              handler.status = @status
            end
          rescue
            @status['error'] = "can't connect"
            EM.stop_event_loop
          end
        end
      end
      
    end
  end
end