class Messed
  module Respond
    
    attr_reader :response
    
    def self.included(c)
      c.instance_eval "
        after_processing :clear_response
      "
    end
    
    def clear_response
      self.response = nil
    end
    
    def say(body)
      set_response "saying #{body}"
    end

    def reply(body)
      set_response "replying #{body}"
    end

    def whisper(body)
      set_response "whisper #{body}"
    end
    
    def set_response(response)
      self.response ?
        raise("you can't do that (#{response}) already have #{response}") :
        (self.response = response)
    end
    
    protected
    attr_writer :response
    
  end
end