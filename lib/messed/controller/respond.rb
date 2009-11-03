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
        set_response response
      end

      def reply(response, options = nil)
        if options && options[:to]
          set_response response, :to => options[:to]
        elsif message.from
          set_response response, :to => message.from
        else
          raise 'no implict recipient'
        end
      end

      def whisper(response, options = nil)
        if options && options[:to]
          set_response body, :to => options[:to], :visibility => :private
        elsif message.from
          set_response body, :to => message.from, :visibility => :private
        else
          raise 'no implict recipient'
        end
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