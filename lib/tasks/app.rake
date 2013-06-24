require 'httparty'
require 'multi_json'
require 'safe_yaml'
require 'uri'

namespace :tachikoma do
  @readable_time = Time.now.utc.strftime('%Y%m%d%H%M%S')
  @root_path = File.expand_path(File.join(__FILE__, '..', '..', '..'))
  @data_path = File.join(@root_path, 'data')
  @repos_path = File.join(@root_path, 'repos')

  # build_for = fenix-knight, github_token_key = TOKEN_FENIX_KNIGHT
  def github_token_key(build_for)
    "TOKEN_#{build_for}".gsub(/-/, '_').upcase
  end

  def authorized_url_with_type(fetch_url, type, github_token, github_account)
    uri = URI.parse(fetch_url)
    if type == 'fork'
      %Q!#{uri.scheme}://#{github_token}@#{uri.host}#{path_for_fork(uri.path, github_account)}!
    elsif type == 'shared'
      "#{uri.scheme}://#{github_token}@#{uri.host}#{uri.path}"
    else
      raise "Invalid type #{type}"
    end
  end

  def path_for_fork(path, github_account)
    path.sub(%r!^/[^/]+!) { '/' + github_account }
  end

  def target_url(fetch_url)
    uri = URI.parse(fetch_url)
    'https://api.github.com/repos/' + uri.path.sub(%r!^/(.*)\.git$!) { $1 } + '/pulls'
  end

  def target_repository_user(type, fetch_url, git_name)
    if type == 'fork'
      uri = URI.parse(fetch_url)
      uri.path.sub(%r!/([^/]+)/.*!) { $1 }
    elsif type == 'shared'
      git_name
    else
      raise "Invalid type #{type}"
    end
  end

  task :load do
    @build_for = ENV['BUILD_FOR']
    @github_token = ENV[github_token_key(@build_for)]
    @git_name = 'bot-motoko'
    @git_email = 'bot-motoko@al.sane.jp'
    @configure =
      YAML.load_file(File.join(@data_path, "#{@build_for}.yaml"))
    @fetch_url = @configure['url']
    @base_remote_branch = 'origin/master'
    @authorized_url = authorized_url_with_type(@fetch_url, @configure['type'], @github_token, @git_name)

    @target_url = target_url(@fetch_url)
    @headers = {
      'User-Agent' => "Tachikoma #{@git_name}",
      'Authorization' => "token #{@github_token}",
      'Accept' => 'application/json',
      'Content-type' => 'application/json',
    }
    @target_head = target_repository_user(@configure['type'], @fetch_url)
    @body = MultiJson.dump({
      title: "Bundle update #{@readable_time}",
      body: ':hamster::hamster::hamster:',
      head: "#{@target_head}:feature/bundle-#{@readable_time}",
      base: 'master',
    })
  end

  task :clean do
    rm_rf(Dir.glob('repos/*'))
  end

  desc 'fetch'
  task fetch: :clean do
    sh "git clone #{@fetch_url} repos/#{@build_for}"
  end

  desc 'bundle'
  task :bundle do
    Dir.chdir("repos/#{@build_for}") do
      Bundler.with_clean_env do
        sh %Q!sed -i -e 's/^ruby/#ruby/' Gemfile!
        sh "git config user.name #{@git_name}"
        sh "git config user.email #{@git_email}"
        sh "git checkout -b feature/bundle-#{@readable_time} #{@base_remote_branch}"
        sh 'bundle --gemfile Gemfile --no-deployment --without nothing'
        sh 'bundle update'
        sh 'git add Gemfile.lock'
        sh %Q!git commit -m "Bundle update #{@readable_time}"!
        sh "git push #{@authorized_url} feature/bundle-#{@readable_time}"
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
