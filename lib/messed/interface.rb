class Messed
  class Interface
    
    include Logger::LoggingModule
    
    autoload :Runner,      File.join('messed', 'interface', 'runner')
    autoload :Adapter,     File.join('messed', 'interface', 'adapter')
    
    def self.interface_from_configuration(booter, name, configuration)
      interface = Interface.new
      interface.send(:name=,          name)
      interface.send(:configuration=, configuration)
      interface.send(:adapter=,       Adapter.for_name(configuration.adapter).new(interface))
      interface.send(:booter=,        booter)
      interface
    end

    def to_s
      "#{Array(configuration['mode']) * ', '} ->> #{name}"
    end
    
    def status
      {
        'adapter' => adapter.status,
        'configuration' => configuration,
        'name' => name
      }
    end
    
    attr_reader :booter, :configuration, :adapter, :name, :started_at

    def initialize
      @started_at = Time.new
    end
    
    def application
      booter.application
    end
    
    def status_host
      configuration.status_address || '0.0.0.0'
    end
    
    def status_port
      configuration.status_port || 11190
    end
    
    def stop
      Process.kill("INT", booter.read_pid_file(configuration.pid_file))
      exit(0)
    end
    
    def start
      begin
        EM.start_server(status_host, status_port, EMRunner::StatusHandler) do |c|
          c.interface = self
        end
        logger.info "Status handler for #{self.class} started on #{status_host}:#{status_port}"
      rescue RuntimeError => e
        if e.message =~ /no acceptor/
          logger.error "Unable to start status handler"
        else
          raise e
        end
          
      end
      booter.write_pid_file(configuration.pid_file)
      adapter.start
    end
    
    protected
    attr_writer :booter, :configuration, :adapter, :name
  end
end