class Messed
  module Tasks
    autoload :Generation, File.join(File.dirname(__FILE__), 'tasks', 'generation')
    autoload :Running,    File.join(File.dirname(__FILE__), 'tasks', 'running')
    autoload :Web,        File.join(File.dirname(__FILE__), 'tasks', 'web')
  end
end