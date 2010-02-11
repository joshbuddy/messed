class Messed
  class Configuration
    
    module ConfigHelper
      
      def with(&block)
        instance_eval(&block)
      end
      
    end
    
    def self.load_from_directory(environment, dir)
      environments = []
      Dir[File.join(dir, '*')].each do |file|
        environments << file if File.directory?(file)
      end

      instance = new(environments, environment)

      instance.instance_eval(File.read(File.join(dir, 'environment.rb')), File.join(dir, 'environment.rb'), 1)
      instance.instance_eval(File.read(File.join(dir, 'environments', "#{environment}.rb")), File.join(dir, 'environments', "#{environment}.rb"), 1)

      instance
    end
    
    class Interfaces
      include ConfigHelper
      
      def initialize
        @interfaces = {}
      end
      
      def each(&block)
        @interfaces.each(&block)
      end
      
      def names
        @interfaces.keys
      end
      
      def method_missing(method, *args, &block)
        @interfaces[method] ||= IndividualInterface.new
      end
      
      class IndividualInterface

        include ConfigHelper

        attr_accessor :adapter, :options, :status_port, :status_address, :pid_file
        
        def initialize
          @options = {}
        end
        
      end
      
    end
    
    class Queues
      include ConfigHelper
      attr_reader :incoming, :outgoing
      
      def initialize
        @incoming = IndivialQueue.new
        @outgoing = IndivialQueue.new
      end
      
      class IndivialQueue
        include ConfigHelper
        attr_accessor :host, :port, :tube
      end
      
    end

    class Application
      include ConfigHelper
      attr_accessor :status_port, :status_address, :pid_file
    end

    include ConfigHelper
    
    attr_reader :queues, :interfaces, :application, :environment, :environments
    attr_accessor :logger, :log_level
    
    def initialize(environments, environment)
      @environments, @environment = environments, environment
      @queues = Queues.new
      @interfaces = Interfaces.new
      @application = Application.new
    end

    
  end
end