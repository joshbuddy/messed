require 'spec/spec_helper'

describe "A Messed application" do
  before(:each) do
    @app = Messed.new(:twitter)
    @incoming = Messed::Queue::Beanstalk.new('incoming')
    @outgoing = Messed::Queue::Beanstalk.new('outgoing')
    @app.incoming = @incoming
    @app.outgoing = @outgoing
    @app.incoming.drain!
    @app.outgoing.drain!
  end

  it "should pass a message in and back out" do
    @app.match {
      always do
        say message
      end
    }
    
    message = @app.message_class.new('my message')
    @app.incoming << message
    @app.process_incoming(false)
    
  end
  
end