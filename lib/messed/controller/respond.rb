class Messed
  class Controller
    module Respond
    
      attr_reader :responses
    
      def self.included(c)
        c.instance_eval "
          after_processing :clear_responses
        "
      end
    
      def clear_responses
        self.responses ? self.responses.clear : @responses = []
      end
    
      def say(body)
        set_response "saying #{body}"
      end

      def reply(body)
        set_response "replying #{body}"
      end

      def whisper(body)
        set_response "whisper #{body}"
      end
    
      def set_response(response)
        self.responses << response
      end
    
    end
  end
end