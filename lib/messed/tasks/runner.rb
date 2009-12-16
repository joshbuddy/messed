class Messed
  module Tasks
    class Runner < Thor

      method_options %w( status_port -s ) => 9000
      method_options %w( pid -p ) => nil
      method_options %w( detach -d ) => false
      method_options %w( environment -e ) => "development"
      desc "interface [NAME]", "starts an interface (#{Messed::Booter.possible_interfaces($root).join(', ')})"
      def interface(name)
        Messed::Booter.new($root, :detach => options.detach?, :pid_file => options.pid, :environment => options.environment, :status_port => options.status_port) do |booter|
          interface = booter.interface_for(name)
          raise("unable to find an interface with name the `#{name}'") unless interface
          interface.start
        end
      end
  
      method_options %w( status_port -s ) => 9000
      method_options %w( pid -p ) => nil
      method_options %w( detach -d ) => false
      method_options %w( environment -e ) => "development"
      desc "application [NAME]", "start the application"
      def application
        Messed::Booter.new($root, :detach => options.detach?, :pid_file => options.pid, :environment => options.environment, :status_port => options.status_port) do |booter|
          application = booter.application
          application.start
        end
      end
  
    end
  end
end