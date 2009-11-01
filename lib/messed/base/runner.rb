require 'thin'

class Messed
  class Base
    class Runner
      
      attr_reader :runnable, :options, :detach
      
      def initialize(runnable, options)
        @runnable = runnable
        @options = options
        @detach = options.key?(:detach) ? options[:detach] : false
      end
      
      def start
        
        runnable.start(detach)
      end
      
    end
  end
end