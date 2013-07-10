require 'httparty'
require 'multi_json'
require 'safe_yaml'
require 'uri'
require 'tachikoma'

namespace :tachikoma do
  # deprecated, this will be removed v3.1.0
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

  def target_repository_user(type, fetch_url, github_account)
    if type == 'fork'
      github_account
    elsif type == 'shared'
      uri = URI.parse(fetch_url)
      uri.path.sub(%r!/([^/]+)/.*!) { $1 }
    else
      raise "Invalid type #{type}"
    end
  end

  task :load do
    @build_for = ENV['BUILD_FOR']
    @github_token = ENV[github_token_key(@build_for)]

    base_config_path = File.join(Tachikoma.original_data_path, 'default.yaml')
    base_config = YAML.safe_load_file(base_config_path) || {}
    user_config_path = File.join(Tachikoma.data_path, "__user_config__.yaml")
    user_config = YAML.safe_load_file(user_config_path) if File.exist?(user_config_path)
    user_config ||= {}
    each_config_path = File.join(Tachikoma.data_path, "#{@build_for}.yaml")
    each_config = YAML.safe_load_file(each_config_path) if File.exist?(each_config_path)
    unless each_config
      fail %Q!Something wrong, BUILD_FOR: #{@build_for}, your config_path: #{each_config_path}!
    end

    @configure = base_config.merge(user_config).merge(each_config)

    @commiter_name = @configure['commiter_name']
    @commiter_email = @configure['commiter_email']
    @github_account = @configure['github_account']
    @fetch_url = @configure['url']
    @base_remote_branch = @configure['base_remote_branch']
    @authorized_url = authorized_url_with_type(@fetch_url, @configure['type'], @github_token, @github_account)
    @timestamp_format = @configure['timestamp_format'] || @default_timestamp_format
    @readable_time = Time.now.utc.strftime(@timestamp_format)

    @target_url = target_url(@fetch_url)
    @headers = {
      'User-Agent' => "Tachikoma #{@github_account}",
      'Authorization' => "token #{@github_token}",
      'Accept' => 'application/json',
      'Content-type' => 'application/json',
    }
    @target_head = target_repository_user(@configure['type'], @fetch_url, @github_account)
    @pull_request_body = @configure['pull_request_body']
    @pull_request_base = @configure['pull_request_base']
    @body = MultiJson.dump({
      title: "Bundle update #{@readable_time}",
      body: @pull_request_body,
      head: "#{@target_head}:feature/bundle-#{@readable_time}",
      base: @pull_request_base,
    })
  end

  task :clean do
    mkdir_p(Tachikoma.repos_path)
    rm_rf(Dir.glob(File.join(Tachikoma.repos_path, '*')))
  end

  desc 'fetch'
  task fetch: :clean do
    sh "git clone #{@fetch_url} #{Tachikoma.repos_path.to_s}/#{@build_for}"
  end

  desc 'bundle'
  task :bundle do
    Dir.chdir("#{Tachikoma.repos_path.to_s}/#{@build_for}") do
      Bundler.with_clean_env do
        sh "git config user.name #{@commiter_name}"
        sh "git config user.email #{@commiter_email}"
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
