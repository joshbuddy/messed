require 'spec/spec_helper'

describe "test" do
  
  include MessedSpecHelper
  
  it "should have a test" do
    process('this is my message')
    outgoing_messages.size.should == 1
    outgoing_messages.first.body.should == "well, that was fun"
  end
end