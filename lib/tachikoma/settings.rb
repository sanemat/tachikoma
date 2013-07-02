require 'pathname'

module Tachikoma
  # ~/users-tachikoma-dir
  def self.root_path
    @root_path ||= Pathname.new(Dir.pwd)
  end

  def self.root_path=(root_path)
    @root_path = Pathname.new File.expand_path(root_path)
  end

  # ~/users-tachikoma-dir/data
  def self.data_path
    @data_path ||= root_path.join('data')
  end

  def self.data_path=(data_path)
    @data_path = Pathname.new File.expand_path(data_path)
  end

  # ~/users-tachikoma-dir/repos
  def self.repos_path
    @repos_path ||= root_path.join('repos')
  end

  def self.repos_path=(repos_path)
    @repos_path = Pathname.new File.expand_path(repos_path)
  end
end
