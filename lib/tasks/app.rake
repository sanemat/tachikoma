namespace :tachikoma do
  desc 'clean'
  task :clean do
    rm_rf(Dir.glob('repos/*'))
  end

  desc 'fetch'
  task fetch: :clean do
    sh 'git clone https://github.com/sanemat/gist-mail.git repos/gist-mail'
  end

  desc 'bundle'
  task :bundle do
    Dir.chdir('repos/gist-mail') do
      Bundler.with_clean_env do
        sh 'git config user.name bot-motoko'
        sh 'git config user.email bot-motoko@al.sane.jp'
        sh 'bundle --gemfile Gemfile'
        sh 'bundle update'
        sh 'git add Gemfile.lock'
        sh 'git commit -m "ooooooo"'
      end
    end
  end

  desc 'pull_request'
  task :pull_request do
    puts 'pull_request!'
  end
end
