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
    puts 'bundle!'
  end

  desc 'pull_request'
  task :pull_request do
    puts 'pull_request!'
  end
end
