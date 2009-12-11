class Messed
  class Matcher
    
    attr_accessor :destination

    def stop_processing?
      true
    end
    
    class Conditional < Matcher

      attr_reader :matches

      def initialize(body_matcher, other_matchers = nil)
        @body_matcher = body_matcher
        @other_matchers = other_matchers
      end

      def match?(message)
        matches = true
        self.matches = nil
        if @body_matcher
          matches &&= @body_matcher === message.body
          self.matches = Regexp.last_match if matches && @body_matcher.is_a?(Regexp)
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

      private
      attr_writer :matches
    end
    
    class Always < Matcher
      
      def match?(message)
        true
      end
      
    end
    
  end
end