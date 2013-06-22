namespace :tachikoma do
  desc 'clean_up'
  task :clean_up do
    rm_rf(Dir.glob('repos/*'))
  end

  desc 'fetch'
  task fetch: :clean_up do
    sh 'git clone https://github.com/sanemat/gist-mail.git repos/gist-mail'
  end

  desc 'bundle'
  task :bundle do
    Dir.chdir('repos/gist-mail') do
      sh 'git config user.name bot-motoko'
      sh 'git config user.email bot-motoko@al.sane.jp'
      sh 'bundle'
      sh 'git add Gemfile.lock'
      sh 'git commit -m "ooooooo"'
    end
  end

  desc 'pull_request'
  task :pull_request do
    puts 'pull_request!'
  end
end
