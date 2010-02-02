class Messed
  module Tasks
    class Runner < Thor

      method_options %w( environment -e ) => "development"
      method_options %w( detach -d ) => false
      desc "interface [NAME] [CMD]", "starts an interface (start|stop)"
      def interface(name)
        Messed::Booter.new($root, :detach => options.detach?, :environment => options.environment) do |booter|
          interface = booter.interface_for(name.to_sym)
          raise("unable to find an interface with name the `#{name}'") unless interface
          case options.cmd
          when 'start'
            interface.start
          when 'stop'
            interface.stop
          end
        end
      end
  
      method_options %w( environment -e ) => "development"
      method_options %w( detach -d ) => false
      desc "application [CMD]", "start the application (start|stop)"
      def application
        Messed::Booter.new($root, :detach => options.detach?, :environment => options.environment) do |booter|
          application = booter.application
          case options.cmd
          when 'start'
            application.start
          when 'stop'
            application.stop
          end
        end
      end
  
      method_options %w( environment -e ) => "development"
      method_options %w( detach -d ) => false
      desc "start all interfaces and application [NAME]", "starts all"
      def all
        Messed::Booter.new($root, :detach => options.detach?, :environment => options.environment) do |booter|
          booter.configuration.interfaces.names.each do |name|
            booter.interface_for(name.to_sym).start
          end
          booter.application.start
        end
      end
  
    end
  end
end