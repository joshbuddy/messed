require 'thin'

class Messed
  class Interface
    class Runner
      
      attr_reader :runnable, :options
      
      def initialize(runnable, options)
        @runnable = runnable
        @options = options
      end
      
      def start
        runnable.start(options[:detach])
      end
      
    end
  end
end