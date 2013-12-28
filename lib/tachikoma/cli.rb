require 'thor'

module Tachikoma
  # Command for Tachikoma
  class CLI < Thor
    include Thor::Actions

    map %w(-v --version) => :version

    desc 'init', 'Initialize files'
    def init
      require 'fileutils'

      copy_or_append_file_lists = %w(
        .gitignore
        Rakefile
        data/__user_config__.yaml
      )
      copy_file_lists = %w(
        repos/.gitkeep
        data/bot-motoko-tachikoma.yaml
      )

      copy_or_append_file_lists.each do |target|
        if File.exist?(target)
          append_to_file target do
            File.read(File.join(self.class.source_root, target))
          end
        else
          copy_file target
        end
      end

      copy_file_lists.each do |target|
        copy_file target
      end

      puts 'tachikoma init completed!'
      puts 'You might want to see README!'
    end

    desc 'version', 'Display Tachikoma gem version'
    def version
      puts Tachikoma::VERSION
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
