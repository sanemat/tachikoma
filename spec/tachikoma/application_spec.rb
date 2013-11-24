require 'tachikoma'
require 'tachikoma/application'
require 'fileutils'

describe Tachikoma::Application do
  before :all do
    ENV.update({ 'BUILD_FOR' => 'test' })
    open(File.join(File.dirname(__FILE__), '..', '..', 'data', 'test.yaml'), 'w') { |f|
      f.puts <<YAML
url:
  'https://github.com/sanemat/bot-motoko-tachikoma.git'
type:
  'fork'
YAML
    }
  end

  after :all do
    ENV.update({ 'BUILD_FOR' => nil })
    FileUtils.rm_f File.join(File.dirname(__FILE__), '..', '..', 'data', 'test.yaml')
  end

  context 'if strategy is `bundle`' do
    before do
      allow_any_instance_of(Tachikoma::Application).to receive(:load)
      allow_any_instance_of(Tachikoma::Application).to receive(:fetch)
      allow_any_instance_of(Tachikoma::Application).to receive(:pull_request)
    end

    it 'should be called `bundle` method' do
      expect_any_instance_of(Tachikoma::Application).to receive(:bundle)
      Tachikoma::Application.run 'bundle'
    end
  end

  context 'if strategy is `carton`' do
    before do
      allow_any_instance_of(Tachikoma::Application).to receive(:load)
      allow_any_instance_of(Tachikoma::Application).to receive(:fetch)
      allow_any_instance_of(Tachikoma::Application).to receive(:pull_request)
    end

    it 'should be called `carton` method' do
      expect_any_instance_of(Tachikoma::Application).to receive(:carton)
      Tachikoma::Application.run 'carton'
    end
  end
end
