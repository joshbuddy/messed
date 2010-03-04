unless Kernel.const_defined?(:ActiveSupport)
  require 'active_support'
end

class Messed
  class Interface
    class Adapter
      
      include Logger::LoggingModule
      
      autoload :TwitterSearch,    File.join('messed', 'interface', 'adapter', 'twitter_search')
      autoload :TwitterSender,    File.join('messed', 'interface', 'adapter', 'twitter_sender')
      autoload :TwitterStreaming, File.join('messed', 'interface', 'adapter', 'twitter_streaming')

      # abstract class for twitter consumption
      autoload :TwitterConsumer,  File.join(File.dirname(__FILE__), 'adapter', 'twitter_consumer')
      
      Registry = {}
      def self.register_for_name(name, class_name)
        Registry[name] = class_name
      end
      
      register_for_name :twitter_search,    'Messed::Interface::Adapter::TwitterSearch'
      register_for_name :twitter_sender,    'Messed::Interface::Adapter::TwitterSender'
      register_for_name :twitter_streaming, 'Messed::Interface::Adapter::TwitterStreaming'
      
      def self.for_name(name)
        class_name = Registry[name]
        class_name ? 
          class_name.constantize :
          raise("No adapter for #{name}")
      end
      
      attr_reader :interface
      
      def initialize(interface)
        @interface = interface
        init
      end
      
      def save_state(state)
        File.open(state_file, 'w') {|f| f << state.to_json }
      end

      def load_state
        JSON.parse(File.read(state_file))
      end
      
      def state_file
        "/tmp/#{name}.state"
      end
      
      # any post initialization goes here
      def init
      end
      
      def type
        raise "method type must be defined"
      end

      def start(detach)
        raise "method start must be defined"
      end

      def send(message)
      end

    end
  end
end
