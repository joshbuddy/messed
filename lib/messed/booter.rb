class Messed
  class Booter
    
    include Logger::LoggingModule
    
    attr_reader :root_directory, :environment, :application, :interface_map
    
    def initialize(root_directory, options = {}, &block)
      if block
        options[:status_port] ||= ((Process.pid % 1000) + 12000)
        EMRunner.new(:detach => options[:detach], :pid_file => options[:pid_file], :status_port => options[:status_port]) {
          setup_booter(root_directory, options)
          yield self
        }
      else
        setup_booter(root_directory, options)
      end
    end
    
    def setup_booter(root_directory, options)
      @root_directory = root_directory
      @environment = options[:environment] || 'development'
      log_level    = options[:log_level] || :debug
      log          = options[:log] || STDOUT
      
      case @log
      when String
        Messed::Logger.instance.setup_logger(File.open(log, File::WRONLY | File::APPEND | File::CREAT), log_level)
      else
        Messed::Logger.instance.setup_logger(log, log_level)
      end

      load_configuration
      load_interfaces
      @application = Messed.new
      @application.configuration = application_configuration
      @application.incoming = create_incoming_queue
      @application.outgoing = create_outgoing_queue
      @application.instance_eval(File.read(runner_file), runner_file)
    end
    
    def self.possible_interfaces(path)
      conf = load_interface_configuration(File.join(path, 'config/interfaces.yml'))
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
    
    def load_interfaces
      @interface_map = {}
      interface_configuration.each do |name, conf|
        logger.info "Loading interface `#{name}'"
        @interface_map[name] = Interface.interface_from_configuration(self, name, conf)
      end
    end
    
    def interface_for(name)
      interface_map[name]
    end
    
    def interface_configuration(interface_config = nil)
      self.class.load_interface_configuration(interface_config || File.join(root_directory, 'config', 'interfaces.yml'))[environment]
    end

    def application_configuration
      YAML.load(File.read(File.join(root_directory, 'config', 'application.yml')))[environment]
    end

    def self.load_interface_configuration(interface_config)
      YAML.load(File.read(interface_config))
    end
    
    def create_incoming_queue
      Messed::Queue::Beanstalk.new('incoming-messages')
    end
    
    def create_outgoing_queue
      Messed::Queue::Beanstalk.new('outgoing-messages')
    end
    
  end
end