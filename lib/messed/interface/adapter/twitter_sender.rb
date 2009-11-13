require 'twitter'
require 'em-jack'

class Messed
  class Interface
    class Adapter
      class TwitterSender < Adapter
        
        def start(detach)
          logger.info "Starting #{interface.name.to_s}"
          pid = EM.fork_reactor do
            trap("INT") { quit }
            EM.run do
              jack = EMJack::Connection.new
              jack.use(interface.application.outgoing.tube) do
                jack.each_job do |job|
                  process_outgoing(job, interface.application.message_class.from_json(job.body))
                end
              end
            end
          end
          
          if detach
            File.open(interface.configuration['pid_file'], 'w') {|f| f << pid} if interface.configuration['pid_file']
            Process.detach(pid)
          else
            trap("INT") { }
            Process.wait(pid)
          end
          pid
        end

        def quit
          EM.stop; logger.info "\nmoooooooo ya later"; exit(0)
        end
        
        def process_outgoing(message)
          job.delete
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