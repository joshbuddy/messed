class Messed
  class Matcher
    
    attr_accessor :destination

    def stop_processing?
      true
    end
    
    class Conditional < Matcher
      
      def initialize(body_matcher, other_matchers = nil)
        @body_matcher = body_matcher
        @other_matchers = other_matchers
      end
      
      def match?(message)
        matches = true
        if @body_matcher
          matches &&= @body_matcher === message.body
        end

        if @other_matchers
          keys = @other_matchers.keys
          unless matches
            key = keys.pop
            matches &&= @other_matchers[key] === message.send(key)
          end
        end
        matches
      end
    end
    
    class Always < Matcher
      
      def match?(message)
        true
      end
      
    end
    
  end
end