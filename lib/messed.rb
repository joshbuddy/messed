require 'usher'

class Messed
  
  autoload :Message, File.join(File.dirname(__FILE__), 'messed', 'message')
  autoload :Respond, File.join(File.dirname(__FILE__), 'messed', 'respond')
  autoload :Helper,  File.join(File.dirname(__FILE__), 'messed', 'helper')

  include Respond

  attr_accessor :params, :message

  def initialize(type = :twitter, &block)
    @type = type
    @router = Usher.new(:delimiters => [' '])
    instance_eval(&block) if block
  end
  
  def with(route, options = nil, &block)
    @router.add_route(route, options).to(extract_destination(options, block))
  end

  def otherwise(options = nil, &block)
    default_destination = extract_destination(options, block)
  end

  def process(message)
    self.message = message
    
    response = @router.recognize_path(message.body)
    destination = if response
      self.params = Hash[*response.params]
      response.path.route.destination
    else
      process_default_destination
    end
    process_destination(destination)
    reset_processing!
  end

  def extract_destination(options, block)
    block ||
      {:controller => options.delete(:controller) || raise("you must supply a controller"), :action => options.delete(:action) || raise("you must supply an action")} ||
      raise("you need to either supply options or a block")
  end
  protected :extract_destination
  
  def reset_processing!
    self.message = nil
    self.params = nil
  end
  protected :reset_processing!
  
  def process_destination(destination)
    if destination.respond_to?(:call)
      instance_eval(&destination)
    else
      class_name = destination[:controller].to_s.split('_').map{|w| w.capitalize}.join
      controller = Kernel.const_get(class_name.to_sym).new
      controller.params = params if controller.respond_to?(:params=)
      controller.message = message if controller.respond_to?(:message=)
      Kernel.const_get(class_name.to_sym).new.method(destination[:action].to_sym).call
    end
  end
  protected :process_destination

end