require "bundler/gem_tasks"
# http://qiita.com/kyanny/items/2de40ca0b5127a0f5c2a
Rake::Task[:release].clear

Dir['lib/tasks/*.rake'].each { |task| load(task) }
