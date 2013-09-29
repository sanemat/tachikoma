require 'tachikoma/application'

namespace :tachikoma do
  desc 'run tachikoma'
  task :run do
    Tachikoma::Application.run
  end

  task :load do
  end

  task :fetch do
  end

  task :bundle do
  end

  task :carton do
  end

  task :pull_request do
  end
end
