require 'pathname'

# Settings of Tachikoma
module Tachikoma
  class << self
    # ~/users-tachikoma-dir
    def root_path
      @root_path ||= Pathname.new Dir.pwd
    end

    def root_path=(root_path)
      @root_path = Pathname.new File.expand_path(root_path)
    end

    # ~/users-tachikoma-dir/data
    def data_path
      @data_path ||= root_path.join('data')
    end

    def data_path=(data_path)
      @data_path = Pathname.new File.expand_path(data_path)
    end

    # ~/users-tachikoma-dir/repos
    def repos_path
      @repos_path ||= root_path.join('repos')
    end

    def repos_path=(repos_path)
      @repos_path = Pathname.new File.expand_path(repos_path)
    end

    # /path/to/gem/tachikoma
    def original_root_path
      @original_root_path ||= Pathname.new File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
    end

    # /path/to/gem/tachikoma/data
    def original_data_path
      @original_data_path ||= original_root_path.join('data')
    end
  end
end
