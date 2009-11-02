class Messed
  class Interface
    autoload :Runner,      File.join(File.dirname(__FILE__), 'interface', 'runner')
    autoload :Adapter,     File.join(File.dirname(__FILE__), 'interface', 'adapter')
    
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
    
    def status_message
      <<-HERE_DOC
Started at #{started_at}
Adapter: #{adapter.status_message}
Running for: #{(Time.new - started_at).to_i}s
      HERE_DOC
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