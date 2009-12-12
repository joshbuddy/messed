require 'beanstalk-client'

class Messed
  class Queue
    
    autoload :Beanstalk, File.join('messed', 'queue', 'beanstalk')
    
    def <<(message)
      raise
    end
    
    def take
      raise
    end
    
  end
end