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
end
