class Messed
  class EMRunner
    
    include Logger::LoggingModule
    
    class StatusHandler < EventMachine::Connection
      
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

    def initialize(options, &block)
      logger.info "Starting... #{options.inspect}"
      if options[:detach]
        $pid = EM.fork_reactor do
          trap("INT") { EM.stop_reactor_loop }
          EM.run do
            EM.next_tick(&block)
          end
        end
        Process.detach(pid)
        exit(0)
      else
        EM.run do
          EM.next_tick(&block)
        end
      end
    end

    def quit
      EM.stop; logger.info "\nStoping #{interface.name.to_s}"; exit(0)
    end
    
  end
end