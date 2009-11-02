class Messed
  class Booter
    
    attr_reader :root_directory, :environment, :interface_map, :application
    
    def initialize(root_directory, environment = 'development')
      @root_directory, @environment = root_directory, environment
      load_configuration
      load_adapters
      @application = Messed.new
      @application.incoming = create_incoming_queue
      @application.outgoing = create_outgoing_queue
      p File.read(runner_file)
      
      @application.instance_eval(File.read(runner_file))
    end
    
    def self.possible_adapters(path)
      conf = load_adapter_configuration(File.join(path, 'config/adapters.yml'))
      conf[conf.keys.first].keys
    end
    
    def configuration_file
      File.join(root_directory, 'config/application.rb')
    end
    
    def runner_file
      File.join(root_directory, 'app/runner.rb')
    end
    
    def environmental_configuration_file
      File.join(root_directory, "config/environments/#{environment}.rb")
    end
    
    def load_configuration
      instance_eval File.read(configuration_file)
      instance_eval File.read(environmental_configuration_file) if File.exist?(environmental_configuration_file)
    end
    
    def load_adapters
      @interface_map = {}
      adapter_configuration.each do |name, conf|
        puts "#{name} -> #{conf.inspect}"
        @interface_map[name] = Interface.interface_from_configuration(self, name, conf)
      end
    end
    
    def adapter_configuration(adapter_config = nil)
      self.class.load_adapter_configuration(adapter_config || File.join(root_directory, 'config/adapters.yml'))[environment]
    end

    def self.load_adapter_configuration(adapter_config)
      YAML.load(File.read(adapter_config))
    end
    
    def create_incoming_queue
      Messed::Queue::Beanstalk.new(application, 'incoming-messages')
    end
    
    def create_outgoing_queue
      Messed::Queue::Beanstalk.new(application, 'outgoing-messages')
    end
    
  end
end