require 'fileutils'

class Messed
  class Booter
    
    include Logger::LoggingModule
    
    attr_reader :root_directory, :environment, :application, :interface_map, :configuration, :pid
    
    def initialize(root_directory, options = {}, &block)
      if block
        EMRunner.new(:detach => options[:detach]) {
          setup_booter(root_directory, options)
          record_pid(Process.pid)
          yield self
        }
      else
        setup_booter(root_directory, options)
      end
    end
    
    def setup_booter(root_directory, options)
      $LOAD_PATH << File.expand_path(root_directory)
      
      @root_directory = root_directory
      @environment = options[:environment] || 'development'

      load_configuration
      prepare_root
      setup_logger
      setup_queues
      setup_interfaces
      setup_application
    end

    def record_pid(pid)
      @pid = pid
    end

    def write_pid_file(pid_file)
      File.open(File.expand_path(pid_file, root_directory), 'w') {|f| f << pid} if pid_file
    end

    def prepare_root
      FileUtils.mkdir_p(File.join(root_directory, 'log'))
      FileUtils.mkdir_p(File.join(root_directory, 'tmp', 'pid'))
    end

    def load_configuration
      @configuration = Configuration.load_from_directory(@environment, File.expand_path(File.join(root_directory, 'config')))
    end

    def setup_queues
      @incoming_queue = create_incoming_queue
      @outgoing_queue = create_outgoing_queue
    end
    
    def setup_application
      @application = Messed.new
      @application.booter = self
      @application.incoming = create_incoming_queue
      @application.outgoing = create_outgoing_queue
      @application.instance_eval(File.read(runner_file), runner_file)
    end

    def setup_logger
      Messed::Logger.instance.setup_logger(configuration.logger || ::Logger.new(File.open(File.join(root_directory, 'log', "#{environment}.log"), File::WRONLY | File::APPEND | File::CREAT)), configuration.log_level || :debug)
    end
    
    def self.possible_interfaces(path)
      booter = new(path)
      booter.configuration.interfaces.names
    end
    
    def runner_file
      File.join(root_directory, 'app/runner.rb')
    end
    
    def environmental_configuration_file
      File.join(root_directory, "config/environments/#{environment}.rb")
    end
    
    def setup_interfaces
      @interface_map = {}
      configuration.interfaces.each do |name, conf|
        logger.info "Loading interface `#{name}'"
        @interface_map[name] = Interface.interface_from_configuration(self, name, conf)
      end
    end
    
    def interface_for(name)
      interface_map[name]
    end
    
    def create_incoming_queue
      Messed::Queue::Beanstalk.new(configuration.queues.incoming.tube, configuration.queues.incoming.host, configuration.queues.incoming.port)
    end
    
    def create_outgoing_queue
      Messed::Queue::Beanstalk.new(configuration.queues.outgoing.tube, configuration.queues.outgoing.host, configuration.queues.outgoing.port)
    end
    
  end
end