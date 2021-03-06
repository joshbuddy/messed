class Messed
  module Tasks
    class Status < Thor

      desc "Status", "status"
      method_options :environment => "development"
      def status
        booter = Messed::Booter.new($root, options.environment)
    
        puts "=Queues"
        puts "==Incoming"
        booter.application.incoming.status.each {|k,v|
          puts "  %40s - %s" % [k, v]
        }

        puts "==Outgoing"
        booter.application.outgoing.status.each {|k,v|
          puts "  %40s - %s" % [k, v]
        }
    
        puts "=Interfaces"
        booter.interface_map.each {|name, interface|
          puts "==#{interface.name}"
          Messed::Util::RemoteStatus.new(interface.configuration.options['host'], interface.configuration.options['port']).status.each {|k,v|
            puts "  %40s - %s" % [k, v]
          }
        }
    
        puts "=Application"
        Messed::Util::RemoteStatus.new(booter.application.configuration['host'], booter.application.configuration['port']).status.each {|k,v|
          puts "  %40s - %s" % [k, v]
        }
      end
  
    end
  end
end
