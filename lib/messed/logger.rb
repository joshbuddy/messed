require 'logger'

class Messed
  class Logger
    module LoggingModule
      def self.included(cls)
        cls.class_eval(<<-HERE_DOC, __FILE__, __LINE__)
      
        def self.logger
          Messed::Logger.instance.logger
        end
      
        def self.logger=(logger)
          Messed::Logger.instance.logger = logger
        end
      
        HERE_DOC
      end
      
      def logger
        Messed::Logger.instance.logger
      end

      def logger=(logger)
        Messed::Logger.instance.logger = logger
      end

    end
    
    def initialize
      
    end
    private :initialize
    
    @@instance = self.new
    
    def self.instance
      @@instance
    end
    
    def setup
      @logger ||= ::Logger.new(STDOUT)
    end

    def logger
      setup
      @logger
    end
    
    attr_writer :logger
    
  end
end
    