class Messed
  module Tasks
    autoload :Generation, File.join('messed', 'tasks', 'generation')
    autoload :Running,    File.join('messed', 'tasks', 'running')
    autoload :Web,        File.join('messed', 'tasks', 'web')
  end
end