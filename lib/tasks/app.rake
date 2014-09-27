require 'tachikoma/application'

namespace :tachikoma do
  desc 'run tachikoma with bundle'
  task :run_bundle do
    Tachikoma::Application.run 'bundle'
  end

  desc 'run tachikoma with carton'
  task :run_carton do
    Tachikoma::Application.run 'carton'
  end

  desc 'run tachikoma with none'
  task :run_none do
    Tachikoma::Application.run 'none'
  end

  desc 'run tachikoma with david'
  task :run_david do
    Tachikoma::Application.run 'david'
  end

  desc 'run tachikoma with composer'
  task :run_composer do
    Tachikoma::Application.run 'composer'
  end
end
