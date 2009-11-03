class Messed
  class Queue
    class Beanstalk < Queue

      attr_accessor :application
      
      def initialize(tube, connection = 'localhost:11300')
        @beanstalk = ::Beanstalk::Pool.new(Array(connection))
        @tube = tube
        @beanstalk.use(tube)
        @beanstalk.watch(tube)
      end
      
      def take
        job = beanstalk.reserve
        yield application.message_class.from_json(job.body)
        job.delete
      end
      
      def <<(message)
        beanstalk.put message.to_json
      end
      
      def jobs_available?
        not jobs_available.zero?
      end
      
      def drain!
        while jobs_available?
          take do |job|
            'do nothing'
          end
        end
      end
      
      def jobs_available
        beanstalk.stats_tube(tube)['current-jobs-ready']
      end
      protected
      attr_reader :beanstalk, :tube
      
    end
  end
end