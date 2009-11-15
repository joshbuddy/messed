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
            http = if message.in_reply_to
              req.post(:body => {:user => message.to_user_id, :text => message.body, :in_reply_to => message.in_reply_to}, :timeout => 30)
            else
              req.post(:body => {:user => message.to_user_id, :text => message.body}, :timeout => 30)
            end
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
          
          #httpauth = Twitter::HTTPAuth.new(interface.configuration['username'], interface.configuration['username'])
          #client = Twitter::Base.new(httpauth)
          #if message.in_reply_to
          #  client.update(message.body, :in_reply_to_status_id => message.in_reply_to.id)
          #else
          #  client.update(message.body)
          #end
        end
        
      end
    end
  end
end