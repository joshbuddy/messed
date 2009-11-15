require 'spec/spec_helper'
require 'em-http/mock'
require 'rack'

describe "A Messed application", 'twitter sending' do
  before(:all) do
    EventMachine::HttpRequest.register_file("http://twitter.com:80/direct_messages/new.json", :post, File.join(File.dirname(__FILE__), 'http', 'direct_message'))
    EventMachine::HttpRequest.register_file("http://twitter.com:80/statuses/update.json", :post, File.join(File.dirname(__FILE__), 'http', 'update'))

    EventMachine::HttpRequest.pass_through_requests = false
  end
  
  before(:each) do
    EventMachine::HttpRequest.reset_counts!
    @booter = Messed::Booter.new(File.join(File.dirname(__FILE__), 'applications', 'twitter_sender'))
    @booter.application.incoming.drain!
    @booter.application.outgoing.drain!
  end
  
  it "should take messages off the outgoing queue and dispatch them to twitter" do
    @booter.application.incoming << Messed::Message::Twitter.new {|m| m.body = 'say' }
    @booter.application.incoming << Messed::Message::Twitter.new {|m| m.body = 'reply'; m.from = 'josh' }
    @booter.application.incoming << Messed::Message::Twitter.new {|m| m.body = 'whisper'; m.from = 'josh' }

    @booter.application.match {
      with 'say' do
        say message
      end

      with 'reply' do
        reply message
      end

      with 'whisper' do
        whisper message
      end
    }

    @booter.application.process_incoming(false)
    
    Thread.new {
      Messed::Interface::Runner.new(@booter.interface_map['twitter_sender'], :detach => false).start
    }.join(1)
    
    @booter.application.outgoing.jobs_available.should == 0
    EventMachine::HttpRequest.count("http://twitter.com:80/direct_messages/new.json", "POST").should == 1
    EventMachine::HttpRequest.count("http://twitter.com:80/statuses/update.json", "POST").should == 2
    
    
  end
  
end