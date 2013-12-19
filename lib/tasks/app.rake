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

  # Deprecated: Please use `tachikoma:run_bundle` or `tachikoma:run_carton` instead
  task :load do
    warn '[DEPRECATION] `tachikoma:load` is deleted. Please use `tachikoma:run_bundle` or `tachikoma:run_carton instead.'
  end

  # Deprecated: Please use `tachikoma:run_bundle` or `tachikoma:run_carton` instead
  task :fetch do
    warn '[DEPRECATION] `tachikoma:fetch` is deleted. Please use `tachikoma:run_bundle` or `tachikoma:run_carton instead.'
  end

  # Deprecated: Please use `tachikoma:run_bundle` or `tachikoma:run_carton` instead
  task :bundle do
    warn '[DEPRECATION] `tachikoma:bundle` is deprecated. Please use `tachikoma:run_bundle` or `tachikoma:run_carton` instead.'
    Tachikoma::Application.run 'bundle'
  end

  # Deprecated: Please use `tachikoma:run_bundle` or `tachikoma:run_carton` instead
  task :carton do
    warn '[DEPRECATION] `tachikoma:carton` is deprecated. Please use `tachikoma:run_bundle` or `tachikoma:run_carton` instead.'
    Tachikoma::Application.run 'carton'
  end

  # Deprecated: Please use `tachikoma:run_bundle` or `tachikoma:run_carton` instead
  task :pull_request do
    warn '[DEPRECATION] `tachikoma:pull_request` is deleted. Please use `tachikoma:run_bundle` or `tachikoma:run_carton` instead.'
  end
end
