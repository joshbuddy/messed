require 'spec/spec_helper'
require 'em-http/mock'
require 'rack'

describe "A Messed application", 'twitter searching' do
  before(:all) do 
    EventMachine::HttpRequest.register_file("http://search.twitter.com:80/search.json?q=love", :get, File.join(File.dirname(__FILE__), 'http', 'twitter_search'))
    EventMachine::HttpRequest.pass_through_requests = false
  end
  
  before(:each) do
    @booter = Messed::Booter.new(File.join(File.dirname(__FILE__), 'applications', 'twitter_search'))
    @booter.application.incoming.drain!
    @booter.application.outgoing.drain!
  end
  
  it "should take a twitter search and process them" do
    @booter.application.match {
      always do
        say message
      end
    }

    pid = Messed::Interface::Runner.new(@booter.interface_for('search'), :detach => true).start
    sleep(1)

    Process.kill('INT', pid)
    @booter.application.incoming.jobs_available.should == 15
    @booter.application.do_work(false)
    @booter.application.outgoing.jobs_available.should == 15
    
    
  end
  
end