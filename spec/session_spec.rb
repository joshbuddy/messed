require 'spec/spec_helper'

describe "A Messed application", 'sessions' do
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
        session[:sent_count] ||= 0
        session[:sent_count] += 1
        say "i got #{session[:sent_count]} messages"
        session.clear if session[:sent_count] >= 2
      end
    }
    
    message = @app.message_class.new('my message')
    message.from = 'josh'
    message.from_user_id = 1234
    @app.incoming << message
    @app.process_incoming(false)
    @app.outgoing.take{|m| m.body.should == "i got 1 messages"}
    @app.incoming << message
    @app.process_incoming(false)
    @app.outgoing.take{|m| m.body.should == "i got 2 messages"}
  end
  
end