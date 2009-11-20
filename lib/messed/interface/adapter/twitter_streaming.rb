class Messed
  class Interface
    class Adapter
      class TwitterStreamer < TwitterConsumer
        
        def do_work
          stream = Twitter::JSONStream.connect(
            :path    => "/1/statuses/#{interface.configuration['type']}.json?track=football",
            :auth    => "#{interface.configuration['username']}:#{interface.configuration['password']}"
          )
          
          stream.each_item do |item|
            self.last_ok = Time.new
            result = JSON.parse(item)
            message = Message::Twitter.new do |m|
              m.body = result['text']
              m.from = result['from_user']
              m.to = result['to_user_id']
              m.created_at = Time.rfc2822(result['created_at'])
              m.profile_image_url = result['profile_image_url']
              m.id = result['id']
              m.geo = result['geo']
              m.from_user_id = result['from_user_id']
              m.iso_language_code = result['iso_language_code']
              m.source = result['source']
            end
            self.packets_processed += 1
            interface.application.incoming << message
          end

          stream.on_error do |message|
            self.errors += 1
            self.last_error = message
          end

          stream.on_max_reconnects do |timeout, retries|
            # Something is wrong on your side. Send yourself an email.
          end
        end
        
      end
    end
  end
end