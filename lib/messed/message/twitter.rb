class Messed
  class Message
    class Twitter < Message

      attr_accessor :created_at, :profile_image_url, :id, :geo, :from_user_id, :iso_language_code, :source, :private
      hash_accessor :profile_image_url, :id, :geo, :from_user_id, :iso_language_code, :source
      hash_convert  :created_at => Hashify::Convert::Time
      hash_convert  :private => [proc{|x| !!x}, proc{|x| !!x}]
      
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
      