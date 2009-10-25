class Messed
  module Processing
    def self.included(target)
      
      
      target.send(:class_variable_set, :@@after, []) unless target.send(:class_variable_defined?, :@@after)
      target.class_eval "

        def self.after_processing(t)
          @@after << t
        end

        def reset_processing!
          @@after.each {|a| send(a)}
        end
      "
      
    end
  end
end