require 'beanstalk-client'

class Messed
  class Queue
    
    autoload :Beanstalk, File.join(File.dirname(__FILE__), 'queue', 'beanstalk')
    
    def <<(message)
      raise
    end
    
    def take
      raise
    end
    
  end
end