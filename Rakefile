require "bundler/gem_tasks"
require "bundler/gem_helper"

# http://qiita.com/kyanny/items/2de40ca0b5127a0f5c2a
Rake::Task[:release].clear

# http://qiita.com/kyanny/items/d3111ea76b2941d71ef5
t = Bundler::GemHelper.new
desc "Create tag #{t.send(:version_tag)}"
task :tag do
  t.send(:tag_version) { t.send(:git_push) } unless t.send(:already_tagged?)
end

Dir['lib/tasks/*.rake'].each { |task| load(task) }
