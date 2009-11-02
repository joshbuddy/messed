class Messed
  class Controller

    autoload :Processing,  File.join(File.dirname(__FILE__), 'controller', 'processing')
    autoload :Respond,     File.join(File.dirname(__FILE__), 'controller', 'respond')
    autoload :Helper,      File.join(File.dirname(__FILE__), 'controller', 'helper')

    def self.inherited(subclass)
      subclass.instance_eval "
        include Messed::Controller::Helper
        include Messed::Controller::Processing
        include Messed::Controller::Respond
      "
    end
    
  end
end