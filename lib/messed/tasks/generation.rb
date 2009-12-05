class Messed
  module Tasks
    class Generation
      
      def initialize(name)
        Dressmaker.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'patterns', 'messed'), File.join(Dir.pwd, name)).generate(:app_name => name)
      end
      
    end
    
  end
end