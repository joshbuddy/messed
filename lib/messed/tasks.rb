class Messed
  module Tasks
    autoload :Generation, File.join('messed', 'tasks', 'generation')
    autoload :Runner,     File.join('messed', 'tasks', 'runner')
    autoload :Web,        File.join('messed', 'tasks', 'web')
  end
end