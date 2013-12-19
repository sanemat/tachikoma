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

  task :load do
  end

  task :fetch do
  end

  task :bundle do
    Tachikoma::Application.run 'bundle'
  end

  task :carton do
    Tachikoma::Application.run 'carton'
  end

  task :pull_request do
  end
end
