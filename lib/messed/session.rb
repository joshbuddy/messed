class Messed
  class Session

    autoload :Memcache,     File.join(File.dirname(__FILE__), 'session', 'memcache')
    
  end
end