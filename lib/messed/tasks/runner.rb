class Messed
  module Tasks
    class Runner < Thor

      method_options :detach => false
      method_options :environment => "development"
      desc "interface [NAME]", "starts an interface (#{Messed::Booter.possible_interfaces($root).join(', ')})"
      def interface(name)
        booter = Messed::Booter.new($root, options.environment)
        interface = booter.interface_for(name)
    
        raise("unable to find an interface with name the `#{name}'") unless interface
    
        Messed::Interface::Runner.new(interface, :detach => options.detach?).start
      end
  
      method_options :detach => false
      method_options :environment => "development"
      desc "application [NAME]", "start the application"
      def application
        booter = Messed::Booter.new($root, options.environment)
        application = booter.application
        Messed::Interface::Runner.new(application, :detach => options.detach?).start
      end
  
    end
  end
end