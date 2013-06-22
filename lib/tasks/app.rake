require 'httparty'
require 'multi_json'

namespace :tachikoma do
  @git_name = 'bot-motoko'
  @git_email = 'bot-motoko@al.sane.jp'
  @readable_time = Time.now.utc.strftime('%Y%m%d%H%M%S')
  @github_token = ENV['TOKEN_FENIX_KNIGHT']
  @target_url = 'https://api.github.com/repos/mrtaddy/fenix-knight/pulls'
  @headers = {
    'User-Agent' => 'Tachikoma bot-motoko',
    'Authorization' => "token #{@github_token}",
    'Accept' => 'application/json',
    'Content-type' => 'application/json',
  }
  @body = MultiJson.dump({
    title: "Bundle update #{@readable_time}",
    body: ':hamster::hamster::hamster:',
    head: "bot-motoko:feature/bundle-#{@readable_time}",
    base: 'master',
  })

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
        sh %Q!sed -i -e 's/^ruby/#ruby/' Gemfile!
        sh "git config user.name #{@git_name}"
        sh "git config user.email #{@git_email}"
        sh "git checkout -b feature/bundle-#{@readable_time} origin/master"
        sh 'bundle --gemfile Gemfile --no-deployment --without nothing'
        sh 'bundle update'
        sh 'git add Gemfile.lock'
        sh %Q!git commit -m "Bundle update #{@readable_time}"!
        sh "git push https://#{@github_token}@github.com/bot-motoko/fenix-knight.git feature/bundle-#{@readable_time}"
      end
    end
  end

  desc 'pull_request'
  task :pull_request do
    puts @headers
    puts @body
    response = HTTParty.post(@target_url, headers: @headers, body: @body)
    unless response.created?
      fail "Do not create pull request yet. #{response.code} #{response.message} #{response.body}"
    end
  end
end
