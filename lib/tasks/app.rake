require 'tachikoma/application'

namespace :tachikoma do
  desc 'run tachikoma'
  task :run do
    Tachikoma::Application.run
  end
end
