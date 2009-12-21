require 'hashify'
require 'logger'
require 'time'
require 'eventmachine'
require 'em-http'
require 'em-beanstalk'
require 'hwia'
require 'active_support'
require 'dressmaker'

$LOAD_PATH << File.dirname(__FILE__)

class Messed
  
  autoload :Booter,             File.join('messed', 'booter')
  autoload :Configuration,      File.join('messed', 'configuration')
  autoload :Controller,         File.join('messed', 'controller')
  autoload :EMRunner,           File.join('messed', 'em_runner')
  autoload :Interface,          File.join('messed', 'interface')
  autoload :Logger,             File.join('messed', 'logger')
  autoload :Matcher,            File.join('messed', 'matcher')
  autoload :Message,            File.join('messed', 'message')
  autoload :Queue,              File.join('messed', 'queue')
  autoload :Session,            File.join('messed', 'session')
  autoload :Tasks,              File.join('messed', 'tasks')
  autoload :Utils,              File.join('messed', 'utils')
  
  module Util
    autoload :RemoteStatus,     File.join('messed', 'util', 'remote_status')
  end
  
  include Logger::LoggingModule
  include Controller::Helper
  include Controller::Processing
  include Controller::Respond

  after_processing :reset!
  
  attr_accessor :controller, :booter, :current_matcher
  attr_reader   :outgoing, :incoming, :matchers, :session_store, :type, :interface, :name,
                :messages_received_count, :messages_sent_count, :last_message_received, :last_message_sent
  
  def initialize(type = :twitter, &block)
    @type = type
    @matchers = []
    @session_store = Session::Memcache.new
    @messages_sent_count = 0
    @messages_received_count = 0
    
    @interface = self
    @name = 'Application'
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
  
  def start(continue_forever = true)
    if EM.reactor_running?

      if booter
        EM.start_server(booter.configuration.application.status_address || '0.0.0.0', booter.configuration.application.status_port || 19191, EMRunner::StatusHandler) do |c|
          c.interface = self
        end
        booter.write_pid_file(booter.configuration.application.pid_file)
      end
      
      @connection = EM::Beanstalk.new
      @connection.watch(incoming.tube) do
        @connection.use(outgoing.tube) do
          process_incoming(continue_forever)
        end
      end
    else
      EM.run {
        start(continue_forever)
      }
    end
  end

  def process_incoming(continue_forever)
    @connection.reserve(continue_forever ? nil : 0.5) { |job|
      begin
        message = message_class.from_json(job.body)
        process_responses process(message)
        job.delete do
          process_incoming(continue_forever)
        end
      rescue JSON::ParserError
        # unrecoverable
        logger.error "message #{job.body} not in JSON format"
        job.delete do
          process_incoming(continue_forever)
        end
      end
    }.on_error { |message|
      EM.stop_event_loop
    }
  end
    
  def process(message)
    increment_messages_received!
    responses = []
    
    self.message = message
    
    session_store.with(message.unique_id) do |session|
      self.session = session
      
      matchers.find do |matcher|
        if matcher.match?(message)
          self.current_matcher = matcher
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
      logger.debug("Putting response #{responses.first.body} onto outgoing queue")
      @connection.put(responses.shift.to_json) do
        increment_messages_sent!
        process_responses(responses)
      end
    end
  end
  
  def status
    {
      :messages_received_count => messages_received_count,
      :messages_sent_count => messages_sent_count,
      :last_message_received => last_message_received,
      :last_message_sent => last_message_sent
    }
  end
  
  def increment_messages_sent!
    @messages_sent_count += 1
    @last_message_sent = Time.new
  end
  
  def increment_messages_received!
    @messages_received_count += 1
    @last_message_received = Time.new
  end
  
end