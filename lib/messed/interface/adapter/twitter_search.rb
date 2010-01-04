require 'set'
require 'rack'

class Messed
  class Interface
    class Adapter
      class TwitterSearch < TwitterConsumer

        attr_reader :packets_processed

        def build_query
          Rack::Utils.build_query(interface.configuration.options[:fetch][:query])
        end
        
        def start
          @ids ||= default_ids
          # do work.
          begin
            query = build_query
            logger.debug "Twitter Search -> #{query.inspect}"
            http = EventMachine::HttpRequest.new("http://#{interface.configuration.options[:fetch][:host]}/#{interface.configuration.options[:fetch][:path]}").
              get(:query => query, :timeout => 30)
            http.callback {
              self.last_status = http.response_header.status
              case http.response_header.status
                when 200
                  self.last_ok = Time.new
                  data = JSON.parse(http.response)
                  interface.configuration.options[:fetch][:query][:since_id] = data['max_id'] if interface.configuration.options[:fetch][:query]
                  @test_set = Set.new(@ids)
                  data['results'].each do |result|
                    result_to_message(result)
                  end
                  trim_ids
              end
              EM.add_timer(interface.configuration.options[:interval]) do
                start
              end
            }
            http.errback {
              self.errors += 1
              self.last_error = Time.new
              EM.add_timer(interface.configuration.options[:interval]) do
                start
              end
            }
          rescue RuntimeError
            EM.add_timer(interface.configuration.options[:interval]) do
              start
            end
          end
        end

        def id_retention_count
          interface.configuration.options[:id_retention_size] || 500
        end

        def trim_ids
          while @ids.size > id_retention_count
            @ids.shift
          end
        end

        def store_ids?
          id_retention_file
        end

        def write_ids
          File.open(id_retention_file, 'w') { |f| f << @ids.to_json }
        end
        
        def read_ids
          @ids = JSON.parse(File.read(id_retention_file))
        end
        
        def default_ids
          store_ids? ? read_ids : []
        rescue 
          logger.error "Twitter Search: Unable to load ids from #{id_retention_file.inspect}"
          []
        end
        
        def id_retention_file
          interface.configuration.options[:id_retention_tmp_file]
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
            @packets_processed += 1
            interface.application.incoming << message
            logger.debug "Twitter Search: Adding message #{message.id}: #{message.body} to incoming queue"
          end
        end

      end
    end
  end
end
