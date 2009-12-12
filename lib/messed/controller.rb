class Messed
  class Controller

    autoload :Processing,  File.join('messed', 'controller', 'processing')
    autoload :Respond,     File.join('messed', 'controller', 'respond')
    autoload :Helper,      File.join('messed', 'controller', 'helper')

    def self.inherited(subclass)
      subclass.instance_eval "
        include Messed::Controller::Helper
        include Messed::Controller::Processing
        include Messed::Controller::Respond
      "
    end
    
  end
end