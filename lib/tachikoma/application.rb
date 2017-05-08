require 'safe_yaml'
require 'uri'
require 'tachikoma'
require 'octokit'
require 'fileutils'
require 'restore_bundled_with'

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
      @depth_option = git_clone_depth_option(@configure['git_clone_depth'])
      @bundler_restore_bundled_with = @configure['bundler_restore_bundled_with']

      @target_head = target_repository_user(@type, @url, @github_account)
      @pull_request_url = repository_identity(@url)
      @pull_request_body = @configure['pull_request_body']
      @pull_request_base = @configure['pull_request_base']
      @pull_request_head = "#{@target_head}:tachikoma/update-#{@readable_time}"
      @pull_request_title = "Exec tachikoma update #{@readable_time}"
    end

    def clean
      mkdir_p(Tachikoma.repos_path)
      rm_rf(Dir.glob(File.join(Tachikoma.repos_path, @build_for, '*')))
    end

    def fetch
      clean
      sh(*([
        'git', 'clone',
        *@depth_option,
        @authorized_base_url,
        "#{Tachikoma.repos_path}/#{@build_for}"
      ].compact))
    end

    def bundler
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        Bundler.with_clean_env do
          sh(*['ruby', '-i', '-pe', '$_.gsub! /^ruby/, "#ruby"', 'Gemfile'])
          sh(*['git', 'config', 'user.name', @commiter_name])
          sh(*['git', 'config', 'user.email', @commiter_email])
          sh(*['git', 'checkout', '-b', "tachikoma/update-#{@readable_time}", @base_remote_branch])
          if File.exist?('Gemfile')
            @bundler_key_file = 'Gemfile'
            @bundler_lock_file = 'Gemfile.lock'
          elsif File.exist?('gems.rb')
            @bundler_key_file = 'gems.rb'
            @bundler_lock_file = 'gems.locked'
          else
            @bundler_key_file = 'Gemfile'
            @bundler_lock_file = 'Gemfile.lock'
          end
          sh(*([
            'bundle',
            '--gemfile', @bundler_key_file,
            '--no-deployment',
            '--without', 'nothing',
            '--path', 'vendor/bundle',
            @parallel_option
          ].compact))
          sh(*%w(bundle update))

          if @bundler_restore_bundled_with
            # restore_bundled_with
            lock_file_contents = File.read(@bundler_lock_file)
            lock_file = RestoreBundledWith::Lock.restore(
              lock_file_contents, @bundler_lock_file)
            File.write(@bundler_lock_file, lock_file.body)
          end

          sh(*['git', 'add', @bundler_lock_file])
          sh(*['git', 'commit', '-m', "Bundle update #{@readable_time}"]) do
            # ignore exitstatus
          end
          sh(*['git', 'push', @authorized_compare_url, "tachikoma/update-#{@readable_time}"])
        end
      end
    end

    def bundle
      warn '[DEPRECATION] `bundle` is deprecated. Please use `bundler` instead.'
      bundler
    end

    def carton
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh(*['git', 'config', 'user.name', @commiter_name])
        sh(*['git', 'config', 'user.email', @commiter_email])
        sh(*['git', 'checkout', '-b', "tachikoma/update-#{@readable_time}", @base_remote_branch])
        sh(*%w(carton install))
        sh(*%w(carton update))
        sh(*['git', 'add', 'carton.lock']) if File.exist?('carton.lock')
        sh(*['git', 'add', 'cpanfile.snapshot']) if File.exist?('cpanfile.snapshot')
        sh(*['git', 'commit', '-m', "Carton update #{@readable_time}"]) do
          # ignore exitstatus
        end
        sh(*['git', 'push', @authorized_compare_url, "tachikoma/update-#{@readable_time}"])
      end
    end

    def none
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh(*['git', 'config', 'user.name', @commiter_name])
        sh(*['git', 'config', 'user.email', @commiter_email])
        sh(*['git', 'checkout', '-b', "tachikoma/update-#{@readable_time}", @base_remote_branch])
        sh(*['git', 'commit', '--allow-empty', '-m', "None update #{@readable_time}"]) do
          # ignore exitstatus
        end
        sh(*['git', 'push', @authorized_compare_url, "tachikoma/update-#{@readable_time}"])
      end
    end

    def david
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh(*['git', 'config', 'user.name', @commiter_name])
        sh(*['git', 'config', 'user.email', @commiter_email])
        sh(*['git', 'checkout', '-b', "tachikoma/update-#{@readable_time}", @base_remote_branch])
        sh(*['david', 'update', '--warn404'])
        if File.exist?('npm-shrinkwrap.json')
          sh(*['rm', '-rf', 'node_modules/', 'npm-shrinkwrap.json'])
          sh(*['npm', 'install'])
          sh(*['npm', 'shrinkwrap'])
          sh(*['git', 'add', 'package.json'])
          sh(*['git', 'add', 'npm-shrinkwrap.json'])
        else
          sh(*['git', 'add', 'package.json'])
        end
        sh(*['git', 'commit', '-m', "David update #{@readable_time}"]) do
          # ignore exitstatus
        end
        sh(*['git', 'push', @authorized_compare_url, "tachikoma/update-#{@readable_time}"])
      end
    end

    def composer
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh(*['git', 'config', 'user.name', @commiter_name])
        sh(*['git', 'config', 'user.email', @commiter_email])
        sh(*['git', 'checkout', '-b', "tachikoma/update-#{@readable_time}", @base_remote_branch])
        # FIXME: Use Octokit.api_endpoint for GitHub Enterprise
        sh(*['composer', 'config', 'github-oauth.github.com', @github_token])
        sh(*['composer', 'install', '--no-interaction'])
        sh(*['composer', 'update', '--no-interaction'])
        sh(*['git', 'add', 'composer.lock'])
        sh(*['git', 'commit', '-m', "Composer update #{@readable_time}"]) do
          # ignore exitstatus
        end
        sh(*['git', 'push', @authorized_compare_url, "tachikoma/update-#{@readable_time}"])
      end
    end

    def carthage
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh(*['git', 'config', 'user.name', @commiter_name])
        sh(*['git', 'config', 'user.email', @commiter_email])
        sh(*['git', 'checkout', '-b', "tachikoma/update-#{@readable_time}", @base_remote_branch])
        sh(*%w(carthage bootstrap))
        sh(*%w(carthage update))
        sh(*['git', 'add', 'Cartfile.resolved'])
        sh(*['git', 'commit', '-m', "Carthage update #{@readable_time}"]) do
          # ignore exitstatus
        end
        sh(*['git', 'push', @authorized_compare_url, "tachikoma/update-#{@readable_time}"])
      end
    end

    def cocoapods
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh(*['git', 'config', 'user.name', @commiter_name])
        sh(*['git', 'config', 'user.email', @commiter_email])
        sh(*['git', 'checkout', '-b', "tachikoma/update-#{@readable_time}", @base_remote_branch])
        sh(*%w(pod install))
        sh(*%w(pod update))
        sh(*['git', 'add', 'Podfile.lock'])
        sh(*['git', 'commit', '-m', "Cocoapods update #{@readable_time}"]) do
          # ignore exitstatus
        end
        sh(*['git', 'push', @authorized_compare_url, "tachikoma/update-#{@readable_time}"])
      end
    end

    def ncu
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh(*['git', 'config', 'user.name', @commiter_name])
        sh(*['git', 'config', 'user.email', @commiter_email])
        sh(*['git', 'checkout', '-b', "tachikoma/update-#{@readable_time}", @base_remote_branch])
        sh(*%w(ncu -u))
        sh(*['git', 'add', 'package.json']) if File.exist?('package.json')
        sh(*['git', 'commit', '-m', "Ncu update #{@readable_time}"]) do
          # ignore exitstatus
        end
        sh(*['git', 'push', @authorized_compare_url, "tachikoma/update-#{@readable_time}"])
      end
    end

    def yarn
      Dir.chdir("#{Tachikoma.repos_path}/#{@build_for}") do
        sh(*['git', 'config', 'user.name', @commiter_name])
        sh(*['git', 'config', 'user.email', @commiter_email])
        sh(*['git', 'checkout', '-b', "tachikoma/update-#{@readable_time}", @base_remote_branch])
        sh(*%w(yarn install))
        sh(*%w(yarn outdated))
        sh(*%w(yarn upgrade))
        sh(*['git', 'add', 'package.json'])
        sh(*['git', 'add', 'yarn.lock'])
        sh(*['git', 'commit', '-m', "Yarn update #{@readable_time}"]) do
          # ignore exitstatus
        end
        sh(*['git', 'push', @authorized_compare_url, "tachikoma/update-#{@readable_time}"])
      end
    end

    def pull_request
      @client = Octokit::Client.new access_token: @github_token
      @client.create_pull_request(
        @pull_request_url,
        @pull_request_base,
        @pull_request_head,
        @pull_request_title,
        @pull_request_body
      )
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

    # TODO: refactor to returning command args array like git clone depth option
    def bundler_parallel_option(bundler_version, parallel_number)
      return if !bundler_parallel_available?(bundler_version) || parallel_number <= 1
      "--jobs=#{parallel_number}"
    end

    def bundler_parallel_available?(bundler_version)
      # bundler 1.4.0 gets parallel number option
      Gem::Version.create(bundler_version) >= Gem::Version.create('1.4.0')
    end

    def git_clone_depth_option(depth)
      return [nil] unless depth
      ['--depth', depth.to_s]
    end
  end
end
