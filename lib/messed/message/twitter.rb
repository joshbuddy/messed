class Messed
  class Message
    class Twitter < Message

      attr_accessor :created_at, :profile_image_url, :id, :geo, :from_user_id, :iso_language_code, :source, :private, :to_user_id
      hash_accessor :profile_image_url, :id, :geo, :from_user_id, :iso_language_code, :source, :to_user_id, :private
      hash_convert  :created_at => Hashify::Convert::Time
      
      def initialize(body = nil)
        super(body)
        self.private = false
      end

      def unique_id
        from_user_id
      end

      alias_method :private?, :private
      
    end
  end
end
      