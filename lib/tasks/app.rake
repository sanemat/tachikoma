namespace :tachikoma do
  @git_name = 'bot-motoko'
  @git_email = 'bot-motoko@al.sane.jp'
  @readable_time = Time.now.utc.strftime('%Y%m%d%H%M%S')

  desc 'clean'
  task :clean do
    rm_rf(Dir.glob('repos/*'))
  end

  desc 'fetch'
  task fetch: :clean do
    sh 'git clone https://github.com/mrtaddy/fenix-knight.git repos/fenix-knight'
  end

  desc 'bundle'
  task :bundle do
    Dir.chdir('repos/fenix-knight') do
      Bundler.with_clean_env do
        sh "git config user.name #{@git_name}"
        sh "git config user.email #{@git_email}"
        sh 'bundle --gemfile Gemfile --no-deployment --without nothing'
        sh 'bundle update'
        sh 'git add Gemfile.lock'
        sh %Q!git commit -m "Bundle update #{@readable_time}"!
      end
    end
  end

  desc 'pull_request'
  task :pull_request do
    puts 'pull_request!'
  end
end
