require 'thor'

module Tachikoma
  class CLI < Thor
    include Thor::Actions

    desc 'init', 'Initialize files'
    def init
      require 'fileutils'
      if File.exist?('.gitignore')
        append_to_file '.gitignore' do
          File.read(File.join(self.class.source_root, '.gitignore'))
        end
      else
        copy_file '.gitignore'
      end
      File.open('Rakefile', 'a') do |f|
        f << <<-EOS

require 'bundler/setup'
require 'tachikoma/tasks'
        EOS
      end
      puts 'appended Rakefile'
      FileUtils.mkdir_p('data')
      puts 'created data/'
      File.open(File.join('data', '__user_config__.yaml'), 'w') do |f|
        f << <<-EOS
        EOS
      end
      puts 'created data/__user_config__.yaml'
      File.open(File.join('data', 'bot-motoko-tachikoma.yaml'), 'w') do |f|
        f << <<-EOS
url:
  'https://github.com/sanemat/bot-motoko-tachikoma.git'
frequency:
  "every 1.day, :at => '6:30 am'"
type:
  'fork'
language:
  'ruby'
version:
  '2.0.0'
        EOS
      end
      puts 'created data/bot-motoko-tachikoma.yaml'
      FileUtils.mkdir_p('repos')
      puts 'created repos/'
      FileUtils.touch(File.join('repos', '.gitkeep'))
      puts 'created repos/.gitkeep'
      puts 'tachikoma init completed!'
      puts 'You might want to see README!'
    end

    def self.help(shell, *)
      list = printable_tasks

      shell.say 'Commands:'
      shell.print_table(list, indent: 2, truncate: true)
      shell.say
      class_options_help(shell)
      shell.say <<-USAGE
Tasks:
  rake tachikoma:run_bundle  # run tachikoma with bundle
  rake tachikoma:run_carton  # run tachikoma with carton
USAGE
    end

    def self.source_root
      File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
    end
  end
end
