require 'memcached'
require 'json'
require 'digest/md5'

class Messed
  class Session
    class Memcache < Session
      
      def initialize(config = "127.0.0.1:11211")
        @connection = Memcached.new(config)
      end
      
      def reset!(id)
        connection.delete(id)
      end
      
      def with(id)
        data = data(id)
        begin
          yield data
        ensure
          connection.set(key(id), data.to_json)
        end
      end
      
      protected
      attr_reader :connection
      
      def data(id)
        JSON.parse(connection.get(key(id))).strhash
      rescue Memcached::NotFound
        StrHash.new
      end
      
      def key(id)
        Digest::MD5.hexdigest(id.to_s)
      end
    end
  end
end