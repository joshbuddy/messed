class Messed
  module Respond
    
    def say(body)
      puts "saying #{body}"
    end

    def reply(body)
      puts "replying #{body}"
    end

    def whisper(body)
      puts "whisper #{body}"
    end
  end
end