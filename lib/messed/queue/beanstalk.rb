class Messed
  class Queue
    class Beanstalk < Queue
      
      def initialize(application, tube, connection = 'localhost:11300')
        @application = application
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
      
      protected
      attr_reader :beanstalk, :tube, :application
      
    end
  end
end