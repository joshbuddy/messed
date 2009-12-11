require 'set'

class Messed
  class Interface
    class Adapter
      class TwitterSearch < TwitterConsumer
        
        def build_query
          Rack::Utils.build_query(interface.configuration['fetch']['query'])
        end
        
        def do_work
          
          @ids ||= []
          
          # do work.
          begin
            query = build_query
            logger.debug "query for twitter_search #{query}"
            http = EventMachine::HttpRequest.new("http://#{interface.configuration['fetch']['host']}/#{interface.configuration['fetch']['path']}").
              get(:query => query, :timeout => 30)
            http.callback {
              self.last_status = http.response_header.status
              case http.response_header.status
              when 200
                self.last_ok = Time.new
                data = JSON.parse(http.response)
                interface.configuration['fetch']['query']['since_id'] = data['max_id'] if interface.configuration['fetch']['query']
                @test_set = Set.new(@ids)
                data['results'].each do |result|
                  result_to_message(result)
                end
                trim_ids
              end
              EM.add_timer(interface.configuration['interval']) do
                do_work
              end
            }
            http.errback {
              self.errors += 1
              self.last_error = Time.new
              EM.add_timer(interface.configuration['interval']) do
                do_work
              end
            }
          rescue RuntimeError
            EM.add_timer(interface.configuration['interval']) do
              do_work
            end
          end
        end
        
        def trim_ids
          while @ids.size > 500
            @ids.shift
          end
        end
        
        def result_to_message(result)
          unless @test_set.include?(result['id'])
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
            @ids << message.id
            self.packets_processed += 1
            interface.application.incoming << message
            logger.debug "putting on #{message.id}"
          end
        end
        
      end
    end
  end
end