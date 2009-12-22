class Messed
  module Tasks
    class Console
      module KeyboardHandler
        include EM::Protocols::LineText2

        attr_accessor :booter

        def log_outgoing(responses)
          if responses.empty?
            puts "No Responses"
          else
            puts "Responding ... #{responses.map{|r| "`#{r.body}'"}.join(', ')}"
          end
        end

        def prompt
          $stdout << ">> "
          $stdout.flush
        end

        def post_init
          prompt
        end
        
        def receive_line(data)
          case data.strip
          when '!q'
            EM.stop_event_loop
            exit
          when '?'
            puts "!q quits"
            puts "Eventhing else is a message"
          else
            log_outgoing(booter.application.process(booter.application.message_class.new(data.strip)))
          end
          prompt
        end
      end

      def self.start
        new.start
      end
      
      def start
        Booter.new($root, :environment => ARGV[0]) do |booter|
          Messed::Logger.instance.setup_logger(::Logger.new(STDOUT), :debug)
          EM.open_keyboard(KeyboardHandler) do |handler|
            handler.booter = booter
          end
        end
      end
  
    end
  end
end