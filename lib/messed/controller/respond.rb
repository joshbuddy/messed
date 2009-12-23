class Messed
  class Controller
    module Respond
    
      def self.included(c)
        c.instance_eval "
          after_processing :clear_responses
        "
      end
    
      def responses
        @response ||= []
      end
    
      def clear_responses
        responses.clear
      end
    
      def say(response)
        set_response(response)
      end

      def reply(response, options = {})
        options[:to] ||= message.from
        options[:from] ||= message.to
        options[:in_reply_to] ||= message
        set_response(response, options)
      end

      def whisper(response, options = {})
        options[:private] = true
        reply(response, options)
      end
    
      def set_response(response, options = nil)
        message = message_class.new
        message.body = response.is_a?(Message) ? response.body : response
        if options
          options.each do |key, value|
            message.send(:"#{key}=", value)
          end
        end
        self.responses << message
      end
    
    end
  end
end