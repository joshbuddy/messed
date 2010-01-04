class Messed
  module Tasks
    class Runner < Thor

      method_options %w( environment -e ) => "development"
      method_options %w( detach -d ) => false
      desc "interface [NAME]", "starts an interface"
      def interface(name)
        Messed::Booter.new($root, :detach => options.detach?, :environment => options.environment) do |booter|
          interface = booter.interface_for(name.to_sym)
          raise("unable to find an interface with name the `#{name}'") unless interface
          interface.start
        end
      end
  
      method_options %w( environment -e ) => "development"
      method_options %w( detach -d ) => false
      desc "application [NAME]", "start the application"
      def application
        Messed::Booter.new($root, :detach => options.detach?, :environment => options.environment) do |booter|
          application = booter.application
          application.start
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