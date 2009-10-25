require 'thor'
require 'active_support'
require 'dressmaker'

class Messed
  module Tasks
    class Generation < Thor
      
      desc "generate APP_NAME", "generate the skeleton for an app called APP_NAME"
      def generate(name)
        Dressmaker.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'dresses', 'messed'), File.join(Dir.pwd, name)).generate
      end
      
    end
    
  end
end