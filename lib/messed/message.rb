class Messed

  class Message

    autoload :Twitter,     File.join(File.dirname(__FILE__), 'message', 'twitter')

    include Hashify
    include Hashify::Json

    attr_accessor :body
    attr_accessor :from
    attr_accessor :to
    attr_accessor :enqueued_at
    
    hash_accessor :body, :from, :to
    hash_convert  :enqueued_at => Hashify::Convert::Time
    
    def initialize(body = nil)
      self.body = body
      yield self if block_given?
    end
    
  end
end