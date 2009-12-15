require 'rubygems'
require 'usher'
require 'lib/messed'


class Hello < Messed::Controller
  
  def _say
    say "you're super awesome"
  end
  
  def jerks
    say "you're super awesome jerk"
  end
  
end

m = Messed.new do 
  with 'hey you jerks', :controller => 'hello', :action => 'jerks'
  with 'hey you', :requirements => {:source => :from_friends} do
    say 'hey hey'
    #reply 'nice to see you guy'
    #whisper 'okay sure'
  end
end

m.outgoing = Messed::Queue::Beanstalk.new('outgoing-messages')
m.incoming = Messed::Queue::Beanstalk.new('incoming')

m.incoming << Messed::Message.new("hey you jerks")
m.incoming << Messed::Message.new("hey you")

m.start
