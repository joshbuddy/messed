require 'hashify'
require 'logger'
require 'time'
require 'eventmachine'
require 'em-http'
require 'em-jack'
require 'hwia'
require 'activesupport'

class Messed
  
  autoload :Message,            File.join(File.dirname(__FILE__), 'messed', 'message')
  autoload :Queue,              File.join(File.dirname(__FILE__), 'messed', 'queue')
  autoload :Controller,         File.join(File.dirname(__FILE__), 'messed', 'controller')
  autoload :Tasks,              File.join(File.dirname(__FILE__), 'messed', 'tasks')
  autoload :Booter,             File.join(File.dirname(__FILE__), 'messed', 'booter')
  autoload :Interface,          File.join(File.dirname(__FILE__), 'messed', 'interface')
  autoload :Utils,              File.join(File.dirname(__FILE__), 'messed', 'utils')
  autoload :Matcher,            File.join(File.dirname(__FILE__), 'messed', 'matcher')
  autoload :Logger,             File.join(File.dirname(__FILE__), 'messed', 'logger')
  autoload :Session,            File.join(File.dirname(__FILE__), 'messed', 'session')
  
  module Util
    autoload :RemoteStatus,     File.join(File.dirname(__FILE__), 'messed', 'util', 'remote_status')
  end
  
  include Logger::LoggingModule
  include Controller::Helper
  include Controller::Processing
  include Controller::Respond
  
  after_processing :reset!
  
  attr_accessor :controller, :configuration
  attr_reader   :outgoing, :incoming, :matchers, :session_store, :type
  
  def initialize(type = :twitter, &block)
    @type = type
    @matchers = []
    @session_store = Session::Memcache.new
    match(&block) if block
  end
  
  def match(&block)
    instance_eval(&block)
  end
  
  def reset!
    matchers.clear
  end
  
  def message_class
    Message.class_for_type(type)
  end
  
  def incoming=(incoming)
    @incoming = incoming
    incoming.application = self
  end
  
  def outgoing=(outgoing)
    @outgoing = outgoing
    outgoing.application = self
  end
  
  def with(*args, &block)
    matchers << if args.first.is_a?(Hash)
      Matcher::Conditional.new(nil, args.first)
    else
      Matcher::Conditional.new(*args, &block)
    end
    matchers.last.destination = block
  end

  def otherwise(options = nil, &block)
    matchers << Matcher::Always.new(&block)
    matchers.last.destination = block
  end
  alias_method :always, :otherwise
  
  def process_incoming(continue_forever = true)
    while continue_forever || incoming.jobs_available?
      incoming.take { |message|
        logger.debug "processing message #{message.inspect}"
        process_responses process(message)
      }
    end
  end

  def start(detach)
    logger.debug "starting application! detach? #{detach}"
    process_incoming
  end
  
  def process(message)
    responses = []
    
    self.message = message
    
    session_store.with(message.unique_id) do |session|
      self.session = session
      
      matchers.find do |matcher|
        logger.debug "testing matching #{matcher.inspect}"
        if matcher.match?(message)
          logger.debug "matched! #{matcher.inspect}"
          controller = process_destination(matcher.destination)
          responses.concat(controller.responses)
          matcher.stop_processing?
        else
          false
        end
      end
    
      controller.reset_processing! if controller.respond_to?(:reset_processing!)
      reset_processing!
    end
    responses
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
    self.session = nil
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

  def process_responses(responses)
    if responses && !responses.size.zero?
      logger.debug("Putting #{responses.inspect} onto outgoing queue")
      responses.each {|response| self.outgoing << response }
    end
  end
  
end