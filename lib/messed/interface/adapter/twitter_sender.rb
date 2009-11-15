require 'twitter'
require 'em-jack'

class Messed
  class Interface
    class Adapter
      class TwitterSender < Adapter
        
        include Messed::Interface::EMRunner
        
        def do_work
          jack = EMJack::Connection.new
          jack.watch(interface.application.outgoing.tube) do
            jack.use(interface.application.outgoing.tube) do
              jack.each_job do |job|
                process_outgoing(job, interface.application.message_class.from_json(job.body))
              end
            end
          end
        end
        
        def process_outgoing(job, message)
          if message.private?
            req = EventMachine::HttpRequest.new("http://twitter.com/direct_messages/new.json")
            data = {:body => {:user => message.to_user_id, :text => message.body}, :timeout => 30, :head => {'authorization' => [interface.configuration['username'], interface.configuration['username']]}}
            data[:body][:in_reply_to] = message.in_reply_to if message.in_reply_to
            http = req.post(data)
            http.callback {
              job.delete
            }
          else
            http = EventMachine::HttpRequest.new("http://twitter.com/statuses/update.json").
              post(:body => {:status => message.body}, :timeout => 30)
            http.callback {
              job.delete
            }
          end
          
        end
        
      end
    end
  end
end