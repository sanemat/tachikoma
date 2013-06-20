require 'pathname'
module Tachikoma
  def self.root
    Pathname.new(File.dirname(File.dirname(File.dirname(__FILE__))))
  end
end
