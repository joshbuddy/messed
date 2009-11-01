class Messed
  class Base
    autoload :Runner,      File.join(File.dirname(__FILE__), 'base', 'runner')
    autoload :Adapter,     File.join(File.dirname(__FILE__), 'base', 'adapter')
    autoload :Incoming,    File.join(File.dirname(__FILE__), 'base', 'incoming')
    autoload :Outgoing,    File.join(File.dirname(__FILE__), 'base', 'outgoing')
    
    def self.base_from_configuration(booter, name, configuration)
      base = Base.new
      base.send(:name=,          name)
      base.send(:configuration=, configuration)
      base.send(:adapter=,       Adapter.for_name(configuration['adapter']).new(base))
      base.send(:booter=,        booter)
      base
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