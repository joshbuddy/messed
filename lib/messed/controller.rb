class Messed
  class Controller

    def self.inherited(subclass)
      subclass.instance_eval "
        include Messed::Helper
        include Messed::Processing
        include Messed::Respond
      "
    end
    
  end
end