class Messed
  class Interface
    autoload :Runner,      File.join('messed', 'interface', 'runner')
    autoload :EMRunner,    File.join('messed', 'interface', 'em_runner')
    autoload :Adapter,     File.join('messed', 'interface', 'adapter')
    
    def self.interface_from_configuration(booter, name, configuration)
      interface = Interface.new
      interface.send(:name=,          name)
      interface.send(:configuration=, configuration)
      interface.send(:adapter=,       Adapter.for_name(configuration['adapter']).new(interface))
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
    
    def start(detach)
      adapter.start(detach)
    end
    
    protected
    attr_writer :booter, :configuration, :adapter, :name
  end
end