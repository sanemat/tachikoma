require 'httparty'
require 'multi_json'
require 'safe_yaml'
require 'uri'
require 'tachikoma'

namespace :tachikoma do
  @default_timestamp_format = '%Y%m%d%H%M%S'

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
      git_name
    elsif type == 'shared'
      uri = URI.parse(fetch_url)
      uri.path.sub(%r!/([^/]+)/.*!) { $1 }
    else
      raise "Invalid type #{type}"
    end
  end

  desc 'fetch another `/data` directory from another location'
  task :fetch_data do
    if ENV['LOCAL_DATA_PATH'] && ENV['LOCAL_DATA_REMOTE_URL']
      raise "local data path is empty"                     if ENV['LOCAL_DATA_PATH'] == ''
      raise "remote git repository of local data is empty" if ENV['LOCAL_DATA_REMOTE_URL'] == ''
      Tachikoma.data_path = File.absolute_path(ENV['LOCAL_DATA_PATH'])
      rm_rf(Tachikoma.data_path) if Dir.exists?(Tachikoma.data_path)
      sh "git clone #{ENV['LOCAL_DATA_REMOTE_URL']} #{Tachikoma.data_path}"
      raise "failed to clone remote repo: perhaps wrong git clone URL? #{ENV['LOCAL_DATA_REMOTE_URL']}" unless $?.success?
    else
      warn "`fetch_data` task requires LOCAL_DATA_PATH and LOCAL_DATA_REMOTE_URL environment variables"
    end
  end

  task :load do
    @build_for = ENV['BUILD_FOR']
    @github_token = ENV[github_token_key(@build_for)]
    @git_name = 'bot-motoko'
    @git_email = 'bot-motoko@al.sane.jp'
    @configure =
      YAML.load_file(File.join(Tachikoma.data_path, "#{@build_for}.yaml"))
    @fetch_url = @configure['url']
    @base_remote_branch = 'origin/master'
    @authorized_url = authorized_url_with_type(@fetch_url, @configure['type'], @github_token, @git_name)
    timestamp_format = @configure['timestamp_format'] || @default_timestamp_format # nil guard
    timestamp_format = @default_timestamp_format if timestamp_format.empty?        # empty string: ""
    @readable_time = Time.now.utc.strftime(timestamp_format)

    @target_url = target_url(@fetch_url)
    @headers = {
      'User-Agent' => "Tachikoma #{@git_name}",
      'Authorization' => "token #{@github_token}",
      'Accept' => 'application/json',
      'Content-type' => 'application/json',
    }
    @target_head = target_repository_user(@configure['type'], @fetch_url, @git_name)
    @body = MultiJson.dump({
      title: "Bundle update #{@readable_time}",
      body: ':hamster::hamster::hamster:',
      head: "#{@target_head}:feature/bundle-#{@readable_time}",
      base: 'master',
    })
  end

  task :clean do
    rm_rf(Dir.glob(Tachikoma.repos_path.to_s))
  end

  desc 'fetch'
  task fetch: :clean do
    mkdir_p(Tachikoma.repos_path.to_s)
    sh "git clone #{@fetch_url} #{Tachikoma.repos_path.to_s}/#{@build_for}"
  end

  desc 'bundle'
  task :bundle do
    Dir.chdir("#{Tachikoma.repos_path.to_s}/#{@build_for}") do
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
