class Messed
  class Interface
    class Adapter
      class TwitterSearch < Adapter
        
        def type
          :twitter
        end
        
        def start(detach)
          puts "Starting #{interface.name.to_s}"
          pid = EM.fork_reactor do
            trap("INT") { EM.stop; puts "\nmoooooooo ya later"; exit(0)}
            EM.run do
              EM.next_tick do
                perform_search
              end
            end
          end
          
          if detach
            File.open(options[:pid], 'w') {|f| f << pid}
            Process.detach(pid)
          else
            trap("INT") { }
            Process.wait(pid)
          end
          
          pid
          
        end
        
        def perform_search
          # do work.
          puts "query!!"
          
          p interface.configuration
          
          http = EM::Protocols::HttpClient.request(
            :host => interface.configuration['fetch']['host'],
            :port => 80,
            :request => interface.configuration['fetch']['path'],
            :query_string => Rack::Utils.build_query(interface.configuration['fetch']['query'])
          )
          http.callback {|response|
            case response[:status]
            when 200
              data = JSON.parse(response[:content])
              interface.configuration['fetch']['query']['since_id'] = data['max_id']
              data['results'].each do |result|
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

                  #{"created_at"=>"Fri, 30 Oct 2009 09:42:30 +0000", "profile_image_url"=>"http://s.twimg.com/a/1256778767/images/default_profile_1_normal.png", "from_user"=>"fortune_sibanda", "text"=>"#SOS09 Section (24)(2)(a) of Bill requires community radios to comply with PFMA. Surely 2 onerous? Gvt dpts cant evn comply with PFMA!!", "to_user_id"=>nil, "id"=>5283471265, "geo"=>nil, "from_user_id"=>71467790, "iso_language_code"=>"en", "source"=>"&lt;a href=&quot;http://twitter.com/&quot;&gt;web&lt;/a&gt;"}         
                end
                
                puts "adding message ... #{message.inspect}"
                
                interface.application.incoming << message
              end
            end
            #puts response[:status]
            #puts response[:headers]
            #puts response[:content]
            EM.add_timer(interface.configuration['interval']) do
              perform_search
            end
          }
        end
        
      end
    end
  end
end