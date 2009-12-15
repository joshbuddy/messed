require 'spec/spec_helper'

describe "A Messed application", 'messaging' do
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
    @app.start(false)
    @app.outgoing.take{|m| m.body.should == message.body}
  end
  
  it "should pass a message in and back out as the reply field" do
    @app.match {
      always do
        reply "thats a nice message!"
      end
    }
    
    message = @app.message_class.new('my message')
    @app.incoming << message
    @app.start(false)
    @app.outgoing.take{|m| m.body.should == 'thats a nice message!'; m.in_reply_to.body.should == message.body}
  end
  
  it "should pass a message in and back out as a private reply" do
    @app.match {
      always do
        whisper "thats a nice message!"
      end
    }
    
    message = @app.message_class.new('my message')
    @app.incoming << message
    @app.start(false)
    @app.outgoing.take{|m| m.body.should == 'thats a nice message!'; m.in_reply_to.body.should == message.body; m.should be_private}
  end
  
end