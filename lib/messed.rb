require 'hashify'
require 'logger'
require 'activesupport'
require 'time'
require 'em-jack'

class Messed
  
  autoload :Processing,  File.join(File.dirname(__FILE__), 'messed', 'processing')
  autoload :Message,     File.join(File.dirname(__FILE__), 'messed', 'message')
  autoload :Respond,     File.join(File.dirname(__FILE__), 'messed', 'respond')
  autoload :Helper,      File.join(File.dirname(__FILE__), 'messed', 'helper')
  autoload :Queue,       File.join(File.dirname(__FILE__), 'messed', 'queue')
  autoload :Controller,  File.join(File.dirname(__FILE__), 'messed', 'controller')
  autoload :Tasks,       File.join(File.dirname(__FILE__), 'messed', 'tasks')
  autoload :Booter,      File.join(File.dirname(__FILE__), 'messed', 'booter')
  autoload :Base,        File.join(File.dirname(__FILE__), 'messed', 'base')
  autoload :Utils,       File.join(File.dirname(__FILE__), 'messed', 'utils')
  autoload :Matcher,     File.join(File.dirname(__FILE__), 'messed', 'matcher')

  include Processing
  include Respond

  after_processing :reset!

  attr_accessor :params, :message, :outgoing, :incoming, :controller
  attr_reader :logger, :matchers
  
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::DEBUG

  def self.logger
    @@logger
  end

  def initialize(type = :twitter, &block)
    @type = type
    @matchers = []
    instance_eval(&block) if block
  end
  
  def message_class
    Message::Twitter
  end

  def logger
    self.class.logger
  end

  def with(*args, &block)
    matchers << if args.first.is_a?(Hash)
      Matcher::Conditional.new(nil, args.first, &block)
    else
      Matcher::Conditional.new(*args, &block)
    end
  end

  def otherwise(options = nil, &block)
    matchers << Matcher::Always.new(&block)
  end

  def process_incoming
    loop do
      incoming.take { |message|
        process(message)
      }
    end
  end

  def start(detach)
    puts "starting application! detach? #{detach}"
    process_incoming
  end
  
  def process(message)
    self.message = message
    
    controllers = Set.new
    
    matchers.find {|matcher|
      if matcher.match?(message)
        controllers << process_destination(matcher.destination)
        matcher.stop_processing?
      else
        false
      end
    }
    
    response = @router.recognize_path(message.body)
    destination = if response
      self.params = Hash[*response.params]
      response.path.route.destination
    else
      process_default_destination
    end
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
  
  def reset!
    self.controller = nil
    self.message = nil
    self.params = nil
  end
  protected :reset!
  
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