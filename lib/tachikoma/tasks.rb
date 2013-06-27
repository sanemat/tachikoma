Dir[File.expand_path(File.join(File.dirname(__FILE__), '..', '..')) + '/lib/tasks/*.rake'].each { |task| load(task) }
