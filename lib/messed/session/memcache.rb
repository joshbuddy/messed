require 'memcached'
require 'json'
require 'digest/md5'

class Messed
  class Session
    class Memcache < Session
      
      def initialize(config = "localhost:11211")
        @connection = Memcached.new(config)
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
        JSON.parse(connection.get(key(id)))
      rescue
        {}
      end
      
      def key(id)
        Digest::MD5.hexdigest(id.to_s)
      end
    end
  end
end