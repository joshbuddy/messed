require 'json'

class Messed
  class Base
    class Adapter
      
      autoload :TwitterSearch,    File.join(File.dirname(__FILE__), 'adapter', 'twitter_search')
      autoload :Twitter,          File.join(File.dirname(__FILE__), 'adapter', 'twitter')
      
      Registry = {}
      def self.register_for_name(name, class_name)
        Registry[name] = class_name
      end
      
      register_for_name 'twitter_search', 'Messed::Base::Adapter::TwitterSearch'
      register_for_name 'twitter',        'Messed::Base::Adapter::Twitter'
      
      def self.for_name(name)
        class_name = Registry[name]
        class_name ? 
          class_name.constantize :
          raise("No adapter for #{name}")
      end
      
      attr_reader :base
      
      def initialize(base)
        @base = base
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
