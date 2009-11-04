class Messed

  class Message

    autoload :Twitter,     File.join(File.dirname(__FILE__), 'message', 'twitter')

    include Hashify
    include Hashify::Json

    attr_accessor :body
    attr_accessor :from
    attr_accessor :to
    attr_accessor :enqueued_at
    attr_accessor :in_reply_to
    
    hash_accessor :body, :from, :to
    hash_convert  :enqueued_at => Hashify::Convert::Time
    hash_convert  :in_reply_to => [proc{|x| x && x.to_hash}, proc{|x, parent| x && parent.class.from_hash(x)}]
    
    def self.class_for_type(type)
      case type
      when :twitter
        Twitter
      else
        raise type
      end
    end

    def initialize(body = nil)
      self.body = body
      yield self if block_given?
    end
    
  end
end