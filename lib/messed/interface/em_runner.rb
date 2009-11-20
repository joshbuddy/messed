class Messed
  class Interface
    module EMRunner
      
      class StatusHandler < EventMachine::Connection
        
        @@available_port = 10000
        
        def self.next_available_port
          port = @@available_port
          @@available_port += 1
          port
        end
        
        attr_accessor :interface
        
        Terminator = "\r\n"
        TerminatorRegex = /\r\n/
        Error = "ERROR\r\n" 
        
        def receive_data(data)
          ss = StringScanner.new(data)
          while part = ss.scan_until(TerminatorRegex)
            if part == 'status'
              send_data(interface.status)
              send_data(Terminator)
            else
              send_data(Error)
            end
          end
        end
      end

      def start(detach)
        logger.info "Starting #{interface.name.to_s}"
        if detach
          interface.configuration['status'] ||= {}
          interface.configuration['status']['port'] ||= StatusHandler.next_available_port
          interface.configuration['status']['address'] ||= '0.0.0.0'
          
          pid = EM.fork_reactor do
            trap("INT") { quit }
            EM.run do
              p interface.configuration
              EM.start_server(interface.configuration['status']['address'], interface.configuration['status']['port'], StatusHandler) do |c|
                c.interface = interface
              end
              do_work
            end
          end
          File.open(interface.configuration['pid_file'], 'w') {|f| f << pid} if interface.configuration['pid_file']
          Process.detach(pid)
          pid
        else
          EM.run do
            do_work
          end
        end
      end

      def quit
        EM.stop; logger.info "\nmoooooooo ya later"; exit(0)
      end
      
    end
  end
end