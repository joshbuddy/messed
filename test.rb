require 'rubygems'
require 'usher'
require 'lib/messed'


class Hello
  
  include Messed::Helper
  include Messed::Respond
  
  def say
    say "you're super awesome"
  end
  
  def jerks
    say "you're super awesome jerk"
  end
  
end

m = Messed.new do 
  with 'hey you', :controller => 'hello', :action => 'say'
  with 'hey you jerks', :controller => 'hello', :action => 'jerks'
  with 'hey you', :requirements => {:source => :from_friends} do
    say 'hey hey'
    reply 'nice to see you guy'
    whisper 'okay sure'
  end
end

m.process(Messed::Message.new("hey you"))
m.process(Messed::Message.new("hey you jerks"))