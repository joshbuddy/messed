class Messed
  class Interface
    module EMRunner

      def start(detach)
        logger.info "Starting #{interface.name.to_s}"
        if detach
          pid = EM.fork_reactor do
            trap("INT") { quit }
            EM.run do
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