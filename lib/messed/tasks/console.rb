class Messed
  module Tasks
    class Console
      
      module KeyboardHandler
        include EM::Protocols::LineText2

        attr_accessor :root, :environment

        def log_outgoing(responses)
          if responses.empty?
            puts "No responses"
          else
            puts "Responding ... #{responses.map{|r| "`#{r.body}'"}.join(', ')}"
          end
        end

        def prompt
          $stdout << ">> "
          $stdout.flush
        end

        def post_init
          print_banner
          prompt
        end

        def print_banner
          puts "?  help"
          puts "!q quit"
          puts "Eventhing else is a message"
        end

        def receive_line(data)
          case data.strip
          when '!q'
            EM.stop_event_loop
            exit
          when '?'
            print_banner
          else
            pid = EM.fork_reactor do
              Booter.new(root, :environment => environment, :supress_banner => true) do |booter|
                Messed::Logger.instance.setup_logger(::Logger.new(STDOUT), :debug)
                log_outgoing(booter.application.process(booter.application.message_class.new(data.strip)))
                EM.stop_event_loop
              end
            end
            Process.wait(pid)
          end
          prompt
        end
      end

      def self.start
        new.start
      end
      
      def start
        EM.run do
          EM.open_keyboard(KeyboardHandler) do |handler|
            handler.root = $root
            handler.environment = ARGV[0]
          end
        end
      end
  
    end
  end
end