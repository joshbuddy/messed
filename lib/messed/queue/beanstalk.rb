class Messed
  class Queue
    class Beanstalk < Queue

      include Logger::LoggingModule

      attr_accessor :application
      attr_reader   :tube
      
      def initialize(tube, connection = '127.0.0.1:11300')
        @beanstalk = ::Beanstalk::Pool.new(Array(connection))
        @tube = tube
        @beanstalk.use(tube)
        @beanstalk.watch(tube)
      end
      
      def status
        @beanstalk.stats_tube(tube)
      end
      
      def take(block = true)
        job = beanstalk.reserve
        begin 
          message = application.message_class.from_json(job.body)
        rescue JSON::ParserError
          logger.error "malformed message #{job.body}"
          job.delete
        else
          yield message
          job.delete
        end
      end
      
      def <<(message)
        beanstalk.put message.to_json
      end
      
      def jobs_available?
        not jobs_available.zero?
      end
      
      def drain!
        while jobs_available?
          beanstalk.reserve.delete
        end
      end
      
      def jobs_available
        beanstalk.stats_tube(tube)['current-jobs-ready']
      end
      protected
      attr_reader :beanstalk
      
    end
  end
end