require 'thor'

module Tachikoma
  class CLI < Thor
    include Thor::Actions

    desc 'init', 'Initialize files'
    def init
      require 'fileutils'

      %w(.gitignore Rakefile repos/.gitkeep data/__user_config__.yaml data/bot-motoko-tachikoma.yaml).each do |target|
        if File.exist?(target)
          append_to_file target do
            File.read(File.join(self.class.source_root, target))
          end
        else
          copy_file target
        end
      end

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
