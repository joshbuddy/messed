class Messed
  class Queue
    class Beanstalk < Queue
      
      def initialize(tube, connection = 'localhost:11300')
        @beanstalk = ::Beanstalk::Pool.new(Array(connection))
        @tube = tube
        @beanstalk.use(tube)
        @beanstalk.watch(tube)
      end
      
      def take
        job = beanstalk.reserve
        yield Messed::Message.from_json(job.body)
        job.delete
      end
      
      def <<(message)
        beanstalk.put message.to_json
      end
      
      protected
      attr_reader :beanstalk, :tube
      
    end
  end
end