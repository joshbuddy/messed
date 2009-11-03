class Messed
  class Message
    class Twitter < Message

      attr_accessor :created_at, :profile_image_url, :id, :geo, :from_user_id, :iso_language_code, :source
      hash_accessor :profile_image_url, :id, :geo, :from_user_id, :iso_language_code, :source
      hash_convert  :created_at => Hashify::Convert::Time
      
      def unique_id
        from_user_id
      end
      
    end
  end
end
      