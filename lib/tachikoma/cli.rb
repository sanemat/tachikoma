require 'thor'

module Tachikoma
  class CLI < Thor
    desc 'init', 'init tachikoma'
    def init
      require 'fileutils'
      File.open('.gitignore', 'a') do |f|
        f << <<-EOS

/repos/*
!/repos/.gitkeep
        EOS
      end
      puts 'appended .gitignore'
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
  end
end
