class Messed
  class Interface
    autoload :Runner,      File.join('messed', 'interface', 'runner')
    autoload :Adapter,     File.join('messed', 'interface', 'adapter')
    
    def self.interface_from_configuration(booter, name, adapter, configuration)
      interface = Interface.new
      interface.send(:name=,          name)
      interface.send(:configuration=, configuration)
      interface.send(:adapter=,       Adapter.for_name(adapter).new(interface))
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
    
    def start
      EM.start_server(configuration[:status_address] || '0.0.0.0', configuration[:status_port] || 11190, EMRunner::StatusHandler) do |c|
        c.interface = self
      end
      adapter.start
    end
    
    protected
    attr_writer :booter, :configuration, :adapter, :name
  end
end