require 'usher'
require 'logger'

class Messed
  
  autoload :Processing,  File.join(File.dirname(__FILE__), 'messed', 'processing')
  autoload :Message,     File.join(File.dirname(__FILE__), 'messed', 'message')
  autoload :Respond,     File.join(File.dirname(__FILE__), 'messed', 'respond')
  autoload :Helper,      File.join(File.dirname(__FILE__), 'messed', 'helper')
  autoload :Queue,       File.join(File.dirname(__FILE__), 'messed', 'queue')
  autoload :Controller,  File.join(File.dirname(__FILE__), 'messed', 'controller')
  autoload :Tasks,       File.join(File.dirname(__FILE__), 'messed', 'tasks')
  autoload :Application, File.join(File.dirname(__FILE__), 'messed', 'application')

  include Processing
  include Respond

  after_processing :clear_message_and_params

  attr_accessor :params, :message, :outgoing, :incoming, :controller
  attr_reader :logger
  
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def self.logger
    @@logger
  end

  def initialize(type = :twitter, &block)
    @type = type
    @router = Usher.new(:delimiters => [' '])
    instance_eval(&block) if block
  end
  
  def logger
    self.class.logger
  end

  def with(route, options = nil, &block)
    @router.add_route(route, options).to(extract_destination(options, block))
  end

  def otherwise(options = nil, &block)
    default_destination = extract_destination(options, block)
  end

  def process_incoming
    loop do
      incoming.take { |message|
        process(message)
      }
    end
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
    controller = process_destination(destination)
    process_response(controller.response)
    controller.reset_processing! if controller.respond_to?(:reset_processing!)
    reset_processing!
  end

  def extract_destination(options, block)
    block ||
      {:controller => options.delete(:controller) || raise("you must supply a controller"), :action => options.delete(:action) || raise("you must supply an action")} ||
      raise("you need to either supply options or a block")
  end
  protected :extract_destination
  
  def clear_message_and_params
    self.controller = nil
    self.message = nil
    self.params = nil
  end
  protected :clear_message_and_params
  
  def process_destination(destination)
    if destination.respond_to?(:call)
      instance_eval(&destination)
      self
    else
      class_name = destination[:controller].to_s.split('_').map{|w| w.capitalize}.join
      self.controller = Kernel.const_get(class_name.to_sym).new
      self.controller.params = params if controller.respond_to?(:params=)
      self.controller.message = message if controller.respond_to?(:message=)
      self.controller.method(destination[:action].to_sym).call
      self.controller
    end
  end
  protected :process_destination

  def process_response(response)
    logger.debug("processing #{response}")
    if response
      logger.debug("Putting #{response} onto outgoing queue")
      self.outgoing = response
    end
  end

end