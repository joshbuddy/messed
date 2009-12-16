class Messed
  class EMRunner
    
    include Logger::LoggingModule
    
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

    def initialize(options, &block)
      logger.info "Starting... #{options.inspect}"
      if options[:detach]
        options[:status_address] ||= '0.0.0.0'
        
        pid = EM.fork_reactor do
          trap("INT") { EM.stop_reactor_loop }
          EM.run do
            EM.start_server(options[:status_address], options[:status_port], StatusHandler) do |c|
              c.interface = interface
            end
            EM.next_tick(&block)
          end
        end
        File.open(options[:pid_file], 'w') {|f| f << pid} if options[:pid_file]
        Process.detach(pid)
        exit(0)
      else
        EM.run do
          options[:status_address] ||= '0.0.0.0'
          EM.start_server(options[:status_address], options[:status_port], StatusHandler) do |c|
            c.interface = interface
          end
          EM.next_tick(&block)
        end
      end
    end

    def quit
      EM.stop; logger.info "\nStoping #{interface.name.to_s}"; exit(0)
    end
    
  end
end