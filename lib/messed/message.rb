require 'json'

class Messed

  class Message

    attr_accessor :body

    # body
    # sender
    # receiver

    # privacy

    def initialize(body = nil)
      self.body = body
      yield self if block_given?
    end
  
    def to_json
      {:body => body}.to_json
    end
  
    def self.from_json(json)
      data = JSON.parse(json)
      Message.new do |m|
        m.body = data['body']
      end
    end
  
  end
end