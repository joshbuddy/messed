require 'spec/spec_helper'

describe Messed::Booter do
  it "should list all the possible interfaces" do 
    Messed::Booter.possible_interfaces(File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'booter'))).should =~ [:search, :twitter_sender]
  end
end
