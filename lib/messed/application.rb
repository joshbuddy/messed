class Messed
  class Application
    
    attr_reader :root_directory
    
    def initialize(root_directory)
      @root_directory = root_directory
      load_configuration
    end
    
    def configuration_file
      File.join(root_directory, 'config/application')
    end
    
    
    def load_configuration
      instance_eval File.read(configuration_file)
      
      
    end
    
  end
end