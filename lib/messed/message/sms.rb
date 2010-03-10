class Messed
  class Message
    class SMS < Message
      
      attr_accessor :created_at, :id, :carrier
      hash_accessor :created_at, :id, :carrier
      hash_convert  :created_at => Hashify::Convert::Time
      
      def initialize(body = nil)
        super(body)
      end
      
    end
  end
end