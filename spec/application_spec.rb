require 'spec/spec_helper'

describe "A Messed application" do
  before(:each) do
    @app = Messed.new(:twitter)
    @app.logger = LOGGER
    @app.incoming = Messed::Queue::Beanstalk.new('incoming')
    @app.outgoing = Messed::Queue::Beanstalk.new('outgoing')
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
    @app.do_work(false)
    @app.outgoing.take{|m| m.body.should == message.body}
  end
  
end