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
    
    attr_accessor :logger
    
    def initialize
      setup_logger
    end
    private :initialize
    
    def self.instance
      @@instance
    end
    
    def setup_logger(logger = ::Logger.new(STDOUT), log_level = :debug)
      @logger = logger
      @logger.level = ::Logger.const_get(log_level.to_s.upcase.to_sym) if log_level
    end
    
    @@instance = self.new

  end
end
    