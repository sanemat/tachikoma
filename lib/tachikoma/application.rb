require 'safe_yaml'
require 'uri'
require 'tachikoma'
require 'octokit'
require 'fileutils'

module Tachikoma
  # Main logic of Tachikoma
  class Application
    include FileUtils

    def self.run(strategy)
      new.run(strategy)
    end

    def run(strategy)
      load
      fetch
      send(strategy) if respond_to?(strategy)
      pull_request
    end

    def load
      @build_for = ENV['BUILD_FOR']
      @github_token = ENV[github_token_key(@build_for)]

      base_config_path = File.join(Tachikoma.original_data_path, 'default.yaml')
      base_config = YAML.safe_load_file(base_config_path) || {}
      user_config_path = File.join(Tachikoma.data_path, '__user_config__.yaml')
      user_config = YAML.safe_load_file(user_config_path) if File.exist?(user_config_path)
      user_config ||= {}
      each_config_path = File.join(Tachikoma.data_path, "#{@build_for}.yaml")
      each_config = YAML.safe_load_file(each_config_path) if File.exist?(each_config_path)
      unless each_config
        fail %(Something wrong, BUILD_FOR: #{@build_for}, your config_path: #{each_config_path})
      end

      @configure = base_config.merge(user_config).merge(each_config)

      @commiter_name = @configure['commiter_name']
      @commiter_email = @configure['commiter_email']
      @github_account = @configure['github_account']
      @url = @configure['url']
      @type = @configure['type']
      @base_remote_branch = @configure['base_remote_branch']
      @authorized_compare_url = authorized_compare_url_with_type(@url, @type, @github_token, @github_account)
      @authorized_base_url = authorized_base_url_with_type(@url, @type, @github_token, @github_account)
      @timestamp_format = @configure['timestamp_format']
      @readable_time = Time.now.utc.strftime(@timestamp_format)
      @parallel_option = bundler_parallel_option(Bundler::VERSION, @configure['bundler_parallel_number'])

      @target_head = target_repository_user(@type, @url, @github_account)
      @pull_request_url = repository_identity(@url)
      @pull_request_body = @configure['pull_request_body']
      @pull_request_base = @configure['pull_request_base']
      @pull_request_head = "#{@target_head}:tachikoma/update-#{@readable_time}"
      @pull_request_title = "Exec tachikoma update #{@readable_time}"
    end

    def clean
      mkdir_p(Tachikoma.repos_path)
      rm_rf(Dir.glob(File.join(Tachikoma.repos_path, '*')))
    end

    def fetch
      clean
      sh "git clone #{@authorized_base_url} #{Tachikoma.repos_path}/#{@build_for}"
    end

    def bundler
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        Bundler.with_clean_env do
          sh *['ruby', '-i', '-pe', '$_.gsub! /^ruby/, "#ruby"', 'Gemfile']
          sh *['git', 'config', 'user.name', @commiter_name]
          sh *['git', 'config', 'user.email', @commiter_email]
          sh *['git', 'checkout', '-b', "tachikoma/update-#{@readable_time}", @base_remote_branch]
          sh *(['bundle', '--gemfile', 'Gemfile', '--no-deployment', '--without', 'nothing', '--path', 'vendor/bundle', @parallel_option].compact)
          sh *['bundle', 'update']
          sh *['git', 'add', 'Gemfile.lock']
          sh *['git', 'commit', '-m', "Bundle update #{@readable_time}"] do; end # ignore exitstatus
          sh *['git', 'push', @authorized_compare_url, "tachikoma/update-#{@readable_time}"]
        end
      end
    end

    def bundle
      warn '[DEPRECATION] `bundle` is deprecated. Please use `bundler` instead.'
      bundler
    end

    def carton
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh "git config user.name #{@commiter_name}"
        sh "git config user.email #{@commiter_email}"
        sh "git checkout -b tachikoma/update-#{@readable_time} #{@base_remote_branch}"
        sh 'carton install'
        sh 'carton update'
        sh 'git add carton.lock' if File.exist?('carton.lock')
        sh 'git add cpanfile.snapshot' if File.exist?('cpanfile.snapshot')
        sh %(git commit -m "Carton update #{@readable_time}") do; end # ignore exitstatus
        sh "git push #{@authorized_compare_url} tachikoma/update-#{@readable_time}"
      end
    end

    def none
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh "git config user.name #{@commiter_name}"
        sh "git config user.email #{@commiter_email}"
        sh "git checkout -b tachikoma/update-#{@readable_time} #{@base_remote_branch}"
        sh %(git commit --allow-empty -m "None update #{@readable_time}") do; end # ignore exitstatus
        sh "git push #{@authorized_compare_url} tachikoma/update-#{@readable_time}"
      end
    end

    def david
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh "git config user.name #{@commiter_name}"
        sh "git config user.email #{@commiter_email}"
        sh "git checkout -b tachikoma/update-#{@readable_time} #{@base_remote_branch}"
        sh 'david update --warn404'
        sh 'git add package.json'
        sh %(git commit -m "David update #{@readable_time}") do; end # ignore exitstatus
        sh "git push #{@authorized_compare_url} tachikoma/update-#{@readable_time}"
      end
    end

    def composer
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh "git config user.name #{@commiter_name}"
        sh "git config user.email #{@commiter_email}"
        sh "git checkout -b tachikoma/update-#{@readable_time} #{@base_remote_branch}"
        # FIXME: Use Octokit.api_endpoint for GitHub Enterprise
        sh "composer config github-oauth.github.com #{@github_token}"
        sh 'composer install --no-interaction'
        sh 'composer update --no-interaction'
        sh 'git add composer.lock'
        sh %(git commit -m "Composer update #{@readable_time}") do; end # ignore exitstatus
        sh "git push #{@authorized_compare_url} tachikoma/update-#{@readable_time}"
      end
    end

    def cocoapods
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh "git config user.name #{@commiter_name}"
        sh "git config user.email #{@commiter_email}"
        sh "git checkout -b tachikoma/update-#{@readable_time} #{@base_remote_branch}"
        sh 'pod install'
        sh 'pod update'
        sh 'git add Podfile.lock'
        sh %(git commit -m "Cocoapods update #{@readable_time}") do; end # ignore exitstatus
        sh "git push #{@authorized_compare_url} tachikoma/update-#{@readable_time}"
      end
    end

    def pull_request
      @client = Octokit::Client.new access_token: @github_token
      @client.create_pull_request(@pull_request_url, @pull_request_base, @pull_request_head, @pull_request_title, @pull_request_body)
    rescue Octokit::UnprocessableEntity
    end

    # build_for = fenix-knight, github_token_key = TOKEN_FENIX_KNIGHT
    def github_token_key(build_for)
      "TOKEN_#{build_for}".gsub(/-/, '_').upcase
    end

    def authorized_compare_url_with_type(fetch_url, type, github_token, github_account)
      uri = URI.parse(fetch_url)
      case type
      when 'fork'
        %(#{uri.scheme}://#{github_token}:x-oauth-basic@#{uri.host}#{path_for_fork(uri.path, github_account)})
      when 'shared'
        "#{uri.scheme}://#{github_token}:x-oauth-basic@#{uri.host}#{uri.path}"
      else
        fail InvalidType, "Invalid type #{type}"
      end
    end

    def authorized_base_url_with_type(fetch_url, type, github_token, _github_account)
      uri = URI.parse(fetch_url)
      case type
      when 'fork', 'shared'
        "#{uri.scheme}://#{github_token}:x-oauth-basic@#{uri.host}#{uri.path}"
      else
        fail InvalidType, "Invalid type #{type}"
      end
    end

    def path_for_fork(path, github_account)
      path.sub(%r{^/[^/]+}) { '/' + github_account }
    end

    def target_repository_user(type, fetch_url, github_account)
      case type
      when 'fork'
        github_account
      when 'shared'
        URI.parse(fetch_url).path.split('/', 3)[1]
      else
        fail InvalidType, "Invalid type: #{type}"
      end
    end

    def repository_identity(url)
      project_name, user_name, _ = url.split('/').reverse
      project_name_identity = strip_extension(project_name)
      user_name + '/' + project_name_identity
    end

    def strip_extension(name)
      /\A(?<identity>.*?)(?:\.git)?\z/ =~ name
      identity
    end

    def bundler_parallel_option(bundler_version, parallel_number)
      # bundler 1.4.0.pre.1 gets parallel number option
      if Gem::Version.create(bundler_version) >= Gem::Version.create('1.4.0.pre.1') && parallel_number > 1
        "--jobs=#{parallel_number}"
      end
    end
  end
end
