require 'pathname'

module Tachikoma
  def self.root_path
    @root_path ||= Pathname.new(File.dirname(File.dirname(File.dirname(__FILE__))))
  end

  def self.root_path=(root_path)
    @root_path = Pathname.new File.expand_path(root_path)
  end

  def self.data_path
    @data_path ||= root_path.parent.join('data')
  end

  def self.data_path=(data_path)
    @data_path = Pathname.new File.expand_path(data_path)
  end

  def self.repos_path
    @repos_path ||= root_path.parent.join('repos')
  end

  def self.repos_path=(repos_path)
    @repos_path = Pathname.new File.expand_path(repos_path)
  end
end
