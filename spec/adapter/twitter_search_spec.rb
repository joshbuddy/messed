require 'spec/spec_helper'
require 'em-http/mock'
require 'rack'

describe "A Messed application", 'twitter searching' do
    
  before(:all) do 
    EventMachine::HttpRequest.register_file("http://search.twitter.com:80/search.json?q=love", :get, File.join(File.dirname(__FILE__), 'http', 'twitter_search'))
    EventMachine::HttpRequest.pass_through_requests = false
  end
  
  it "should take a twitter search and process them" do
    Messed::Booter.new(File.join(File.dirname(__FILE__), 'applications', 'twitter_search')) do |booter|
      booter.application.incoming.drain!
      booter.application.outgoing.drain!
      
      booter.application.match {
        always do
          say message
        end
      }
      
      booter.interface_for('search').start
      EM.add_timer(1) do
        booter.application.incoming.jobs_available.should == 15
        booter.application.start
        EM.add_timer(1) do
          booter.application.outgoing.jobs_available.should == 15
          EM.stop_event_loop
        end
      end
    end
    
  end
  
end