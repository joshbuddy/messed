require 'rubygems'
begin
  require 'messed'
rescue LoadError
  if ENV['MESSED_HOME']
    require File.join(ENV['MESSED_HOME'], 'lib', 'messed')
  else  
    raise("no messed!")
  end
end

class MessedSpecHolder
  
  attr_accessor :booter, :outgoing_messages
  
  def initialize
    @booter = Messed::Booter.new(File.join(File.dirname(__FILE__), '..'))
  end
  
  def application
    @booter.application
  end
  
  def process(message)
    @outgoing_messages = application.process(application.message_class.new(message))
  end
  
end

module MessedSpecHelper

  Holder = MessedSpecHolder.new

  def process(message)
    Holder.process(message)
  end

  def outgoing_messages
    Holder.outgoing_messages
  end
  
end